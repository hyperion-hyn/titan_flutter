import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
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

        try {
          var symbols = DEFAULT_SYMBOLS;
          final symbolString = symbols.reduce((value, element) => value + ',' + element);

          var converts = SupportedQuoteSigns.all.map((sign) => sign.quote).toList();
          var quotes = await _coinMarketApi.quotes(DEFAULT_SYMBOLS, converts);
          currentQuotesModel = QuotesModel(
              quotes: quotes, symbolStr: symbolString, lastUpdateTime: DateTime.now().millisecondsSinceEpoch);

          yield UpdatedQuotesState(quoteModel: currentQuotesModel);
        } catch (e) {
          logger.e(e);

          yield UpdateQuotesFailState();
        }
      }
    } else if (event is UpdateQuotesSignEvent) {
      print("!!!!!0000 ${event.sign}");
      yield UpdatedQuotesSignState(sign: event.sign);
    } else if (event is UpdateGasPriceEvent) {
      yield GasPriceState(status: Status.loading);

      try {
        var response = await HttpCore.instance.get('https://ethgasstation.info/json/ethgasAPI.json');
        var gasPriceRecommend = GasPriceRecommend(
            fast: parseGasPriceToBigIntWei(response['fastest']),
            fastWait: response['fastestWait'],
//            average: parseGasPriceToBigIntWei(response['average']),
            average: parseGasPriceToBigIntWei(response['fast']),
//            avgWait: response['avgWait'],
            avgWait: response['fastWait'],
//            safeLow: parseGasPriceToBigIntWei(response['safeLow']),
//            safeLowWait: response['safeLowWait']);
            safeLow: parseGasPriceToBigIntWei(response['average']),
            safeLowWait: response['avgWait']);

        var btcResponse = await BitcoinApi.requestBtcFeeRecommend();
        if(btcResponse["code"] == 0){
          var btcResponseData = btcResponse["data"];
          var btcGasPriceRecommend = BTCGasPriceRecommend(
              fast: Decimal.fromInt(btcResponseData['fastest']),
              fastWait: double.parse(btcResponseData['fastestWait'].toString()),
              average: Decimal.fromInt(btcResponseData['fast']),
              avgWait: double.parse(btcResponseData['fastWait'].toString()),
              safeLow: Decimal.fromInt(btcResponseData['average']),
              safeLowWait: double.parse(btcResponseData['avgWait'].toString()));
          yield GasPriceState(status: Status.success, gasPriceRecommend: gasPriceRecommend, btcGasPriceRecommend: btcGasPriceRecommend);
        }
      } catch (e) {
        logger.e(e);
        yield GasPriceState(status: Status.failed);
      }
    }
  }

  Decimal parseGasPriceToBigIntWei(double num) {
    return Decimal.parse(num.toString()) / Decimal.fromInt(10) * Decimal.fromInt(TokenUnit.G_WEI);
  }
}
