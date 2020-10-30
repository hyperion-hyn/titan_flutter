import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/components/quotes/vo/symbol_quote_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/utils/future_util.dart';
import '../../../../config.dart';
import '../coin_market_api.dart';
import '../model.dart';
import './bloc.dart';

class QuotesCmpBloc extends Bloc<QuotesCmpEvent, QuotesCmpState> {
  CoinMarketApi _coinMarketApi = CoinMarketApi();

  static const DEFAULT_SYMBOLS = ['ETH', 'HYN', 'USDT', 'BTC'];

  static const UPDATE_THRESHOLD = 5 * 60 * 1000; //5 minute
  QuotesModel currentQuotesModel;

  @override
  QuotesCmpState get initialState => InitialQuotesCmpState();

  @override
  Stream<QuotesCmpState> mapEventToState(QuotesCmpEvent event) async* {
    if (event is UpdateQuotesEvent) {
      if (currentQuotesModel == null ||
          event.isForceUpdate == true ||
          DateTime.now().millisecondsSinceEpoch - currentQuotesModel.lastUpdateTime > UPDATE_THRESHOLD) {
        yield UpdatingQuotesState();

//        try {
          var symbols = DEFAULT_SYMBOLS;
          final symbolString = symbols.reduce((value, element) => value + ',' + element);

          var converts = SupportedQuoteSigns.all.map((sign) => sign.quote).toList();
          var quotes = await _coinMarketApi.quotes(0);
          //hack add (HYN ERC20)quotes
          List<SymbolQuoteVo> addQuotes = [];
          for (var quote in quotes) {
            if (quote.symbol == SupportedTokens.HYN_Atlas.symbol) {
              var q = SymbolQuoteVo.clone(quote);
              q.symbol = SupportedTokens.HYN_ERC20.symbol;
              addQuotes.add(q);
            }
          }
          quotes.addAll(addQuotes);

          currentQuotesModel = QuotesModel(
              quotes: quotes, symbolStr: symbolString, lastUpdateTime: DateTime.now().millisecondsSinceEpoch);

          yield UpdatedQuotesState(quoteModel: currentQuotesModel);
//        } catch (e) {
//          logger.e(e);
//
//          yield UpdateQuotesFailState();
//        }
      }
    } else if (event is UpdateQuotesSignEvent) {
      yield UpdatedQuotesSignState(sign: event.sign);
    } else if (event is UpdateGasPriceEvent) {
      yield GasPriceState(status: Status.loading);
      bool isGasSuccess = false;
      bool isBTCGasSuccess = false;
      try {
        var response = await futureRetry(3, requestGasPrice);
        var gasPriceRecommend = GasPriceRecommend(
            parseGasPriceToBigIntWei(response['fastest']),
            response['fastestWait'],
            parseGasPriceToBigIntWei(response['fast']),
            response['fastWait'],
            parseGasPriceToBigIntWei(response['average']),
            response['avgWait']);

        await AppCache.saveValue(PrefsKey.SHARED_PREF_GAS_PRICE_KEY, json.encode(gasPriceRecommend.toJson()));
        yield GasPriceState(status: Status.success, gasPriceRecommend: gasPriceRecommend);
        isGasSuccess = true;

        var btcResponse = await BitcoinApi.requestBtcFeeRecommend();
        if (btcResponse["code"] == 0) {
          var btcResponseData = btcResponse["data"];
          var btcGasPriceRecommend = BTCGasPriceRecommend(
              Decimal.fromInt(btcResponseData['fastest']),
              double.parse(btcResponseData['fastestWait'].toString()),
              Decimal.fromInt(btcResponseData['fast']),
              double.parse(btcResponseData['fastWait'].toString()),
              Decimal.fromInt(btcResponseData['average']),
              double.parse(btcResponseData['avgWait'].toString()));
          await AppCache.saveValue(PrefsKey.SHARED_PREF_BTC_GAS_PRICE_KEY, json.encode(btcGasPriceRecommend.toJson()));
          yield GasPriceState(status: Status.success, btcGasPriceRecommend: btcGasPriceRecommend);
          isBTCGasSuccess = true;
        }
      } catch (e) {
        logger.e(e);
        if (!isGasSuccess) {
          var gasPriceEntityStr = await AppCache.getValue(PrefsKey.SHARED_PREF_GAS_PRICE_KEY);
          if (gasPriceEntityStr != null) {
            yield GasPriceState(status: Status.success, gasPriceRecommend: json.decode(gasPriceEntityStr));
          } else {
            yield GasPriceState(status: Status.failed);
          }
        }
        if (!isBTCGasSuccess) {
          var btcGasPriceEntityStr = await AppCache.getValue(PrefsKey.SHARED_PREF_BTC_GAS_PRICE_KEY);
          if (btcGasPriceEntityStr != null) {
            yield GasPriceState(status: Status.success, btcGasPriceRecommend: json.decode(btcGasPriceEntityStr));
          } else {
            yield GasPriceState(status: Status.failed);
          }
        }
      }
    }
  }

  Future requestGasPrice() async {
    var responseFromEtherScan = await EtherscanApi().getGasFromEtherScan();
    var responseFromEthGasStation = await requestGasFromEthGasStation();
    //print("[object] requestGasPrice，1, responseFromEtherScan:$responseFromEtherScan, responseFromEthGasStation:$responseFromEthGasStation");

    var responseFromEtherScanDict = responseFromEtherScan.data as Map;
    var responseFromEthGasStationDict = responseFromEthGasStation as Map;

    // fastest
    var fastGasPrice = double.parse(responseFromEtherScanDict["FastGasPrice"]) * 10.0;
    var fastest = double.parse(responseFromEthGasStationDict["fastest"].toString());
    responseFromEthGasStationDict["fastest"] = max(fastGasPrice, fastest);

    // fast
    var proposeGasPrice = double.parse(responseFromEtherScanDict["ProposeGasPrice"]) * 10.0;
    var fast = double.parse(responseFromEthGasStationDict["fast"].toString());
    responseFromEthGasStationDict["fast"] = max(proposeGasPrice, fast);

    // average
    var safeGasPrice = double.parse(responseFromEtherScanDict["SafeGasPrice"]) * 10.0;
    var average = double.parse(responseFromEthGasStationDict["average"].toString());
    responseFromEthGasStationDict["average"] = max(safeGasPrice, average);

    //print("[object] requestGasPrice，2, responseFromEtherScanDict:$responseFromEtherScanDict, responseFromEthGasStationDict:$responseFromEthGasStationDict");

    return responseFromEthGasStationDict;
  }

  Future requestGasFromEthGasStation() async {
    var response = await HttpCore.instance.get('https://ethgasstation.info/json/ethgasAPI.json');
    return response;
  }

  Decimal parseGasPriceToBigIntWei(double num) {
    return Decimal.parse(num.toString()) / Decimal.fromInt(10) * Decimal.fromInt(TokenUnit.G_WEI);
  }
}
