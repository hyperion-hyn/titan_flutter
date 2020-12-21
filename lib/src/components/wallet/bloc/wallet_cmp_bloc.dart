import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import '../coin_market_api.dart';
import '../vo/symbol_quote_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/utils/future_util.dart';
import 'package:titan/src/utils/log_util.dart';

import 'bloc.dart';
import '../../../global.dart';
import '../wallet_repository.dart';
import '../vo/wallet_vo.dart';
import '../vo/coin_vo.dart';
import 'dart:math';

class WalletCmpBloc extends Bloc<WalletCmpEvent, WalletCmpState> {
  static const DEFAULT_SYMBOLS = ['ETH', 'HYN', 'USDT', 'BTC'];
  CoinMarketApi _coinMarketApi = CoinMarketApi();

  final WalletRepository walletRepository;

  WalletCmpBloc({@required this.walletRepository});

  WalletVo _activatedWalletVo;

  @override
  WalletCmpState get initialState => InitialWalletCmpState();

  NodeApi _nodeApi = NodeApi();

  int _lastUpdateBalanceTime = 0;

  //fix wallet change stop
//  @override
//  Stream<Transition<WalletCmpEvent, WalletCmpState>> transformEvents(Stream<WalletCmpEvent> events, transitionFn) {
//    return events.switchMap(transitionFn);
//  }

  @override
  Stream<WalletCmpState> mapEventToState(WalletCmpEvent event) async* {
    if (event is ActiveWalletEvent) {
      var isSameWallet = false;

      if (event.wallet == null) {
        _activatedWalletVo = null;
      } else {
        if (_activatedWalletVo?.wallet?.getEthAccount()?.address == event.wallet.getEthAccount().address) {
          isSameWallet = true;
        }
        _activatedWalletVo = walletToWalletCoinsVo(event.wallet);
      }

      if (event.wallet != null && !isSameWallet) {
        _lastUpdateBalanceTime = 0; //set can update balance in time.
        walletRepository.saveActivatedWalletFileName(_activatedWalletVo?.wallet?.keystore?.fileName);

        if (_activatedWalletVo != null) {
          _recoverBalanceFromDisk(_activatedWalletVo);
        }

        //sync wallet account to server
        if (event.wallet?.getBitcoinZPub()?.isNotEmpty ?? false) {
          BitcoinApi.syncBitcoinPubToServer(
              event.wallet.getBitcoinAccount().address, event.wallet?.getBitcoinZPub() ?? "");
        }
//        _nodeApi.postWallets(_activatedWalletVo);

        var userPayload = UserPayloadWithAddressEntity(
            Payload(userName: event?.wallet?.keystore?.name ?? ""), event?.wallet?.getAtlasAccount()?.address ?? "");
        AtlasApi.postUserSync(userPayload);
      }

      yield ActivatedWalletState(walletVo: _activatedWalletVo?.copyWith());
    } else if (event is UpdateActivatedWalletBalanceEvent) {
      //print("[object] --> UpdateActivatedWalletBalanceEvent");

      var nowTime = DateTime.now().millisecondsSinceEpoch;
      //30 second cache time
      bool isOutOfCacheTme = nowTime - _lastUpdateBalanceTime > 10 * 1000;
      if (_activatedWalletVo != null && isOutOfCacheTme) {
        _lastUpdateBalanceTime = nowTime;
        yield UpdatingWalletBalanceState();

        try {
          await walletRepository.updateWalletVoBalance(_activatedWalletVo, event.symbol, event.contractAddress);
          _saveWalletVoBalanceToDisk(_activatedWalletVo); //save balance data to disk;
          yield UpdatedWalletBalanceState(walletVo: _activatedWalletVo.copyWith());
        } catch (e) {
          logger.e(e);

          yield UpdateFailedWalletBalanceState();
        }
      }
    } else if (event is LoadLocalDiskWalletAndActiveEvent) {
//      yield LoadingWalletState();
      try {
        var wallet = await walletRepository.getActivatedWalletFormLocalDisk();
        //now active loaded wallet_vo. tips: maybe null
        add(ActiveWalletEvent(wallet: wallet));
//        await Future.delayed(Duration(milliseconds: 100));
//        add(UpdateActivatedWalletBalanceEvent());
      } catch (e) {
        logger.e(e);

        yield LoadWalletFailState();
      }
    } else if (event is UpdateWalletPageEvent) {
      try {
        var quoteSignStr = await AppCache.getValue<String>(PrefsKey.SETTING_QUOTE_SIGN);
        QuotesSign quotesSign = quoteSignStr != null
            ? QuotesSign.fromJson(json.decode(quoteSignStr))
            : SupportedQuoteSigns.defaultQuotesSign;

        var symbols = DEFAULT_SYMBOLS;
        final symbolString = symbols.reduce((value, element) => value + ',' + element);

        var quotes = await _coinMarketApi.quotes(0);
        var addQuotes = List<SymbolQuoteVo>();
        for (var quote in quotes) {
          if (quote.symbol == SupportedTokens.HYN_Atlas.symbol) {
//            var q = symbolQuoteEntity.SymbolQuoteVo.clone(quote);
            var q = SymbolQuoteVo.clone(quote);
            q.symbol = SupportedTokens.HYN_ERC20.symbol;
            addQuotes.add(q);
          }
        }
        quotes.addAll(addQuotes);

        var currentQuotesModel =
            QuotesModel(quotes: quotes, symbolStr: symbolString, lastUpdateTime: DateTime.now().millisecondsSinceEpoch);

        if (_activatedWalletVo != null) {
          //faster show quote
          yield UpdateWalletPageState(1,
              sign: quotesSign, quoteModel: currentQuotesModel, walletVo: _activatedWalletVo.copyWith());
          await walletRepository.updateWalletVoBalance(_activatedWalletVo);
          _saveWalletVoBalanceToDisk(_activatedWalletVo); //save balance data to disk;
          yield UpdateWalletPageState(0,
              sign: quotesSign, quoteModel: currentQuotesModel, walletVo: _activatedWalletVo.copyWith());
        } else {
          yield UpdateWalletPageState(0,sign: quotesSign, quoteModel: currentQuotesModel);
        }

        if (event.updateGasPrice) {
          BlocProvider.of<WalletCmpBloc>(Keys.rootKey.currentContext).add(UpdateGasPriceEvent());
        }
      } catch (e) {
        LogUtil.toastException(e);
        yield UpdateWalletPageState(-1,walletVo: _activatedWalletVo.copyWith());
      }
    } else if (event is UpdateQuotesEvent) {
      yield UpdatingQuotesState();

      var symbols = DEFAULT_SYMBOLS;
      final symbolString = symbols.reduce((value, element) => value + ',' + element);

      var quotes = await _coinMarketApi.quotes(0);
      List<SymbolQuoteVo> addQuotes = [];
      for (var quote in quotes) {
        if (quote.symbol == SupportedTokens.HYN_Atlas.symbol) {
          var q = SymbolQuoteVo.clone(quote);
          q.symbol = SupportedTokens.HYN_ERC20.symbol;
          addQuotes.add(q);
        }
      }
      quotes.addAll(addQuotes);

      var currentQuotesModel =
          QuotesModel(quotes: quotes, symbolStr: symbolString, lastUpdateTime: DateTime.now().millisecondsSinceEpoch);

      yield UpdatedQuotesState(quoteModel: currentQuotesModel);
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

  /// flat wallet accounts
  WalletVo walletToWalletCoinsVo(Wallet wallet) {
    List<CoinVo> coins = [];
    var hynContractCoin;
    var hynRPContractCoin;
    for (var account in wallet.accounts) {
      // add public chain coin
      CoinVo coin = CoinVo(
        name: account.token.name,
        symbol: account.token.symbol,
        coinType: account.coinType,
        address: account.address,
        decimals: account.token.decimals,
        logo: account.token.logo,
        contractAddress: null,
        extendedPublicKey: account.extendedPublicKey,
        balance: BigInt.from(0),
      );
      coins.add(coin);

      //add contract coin by the chain
      for (var asset in account.contractAssetTokens) {
        CoinVo contractCoin = CoinVo(
          name: asset.name,
          symbol: asset.symbol,
          coinType: account.coinType,
          address: account.address,
          decimals: asset.decimals,
          contractAddress: asset.contractAddress,
          logo: asset.logo,
          balance: BigInt.from(0),
        );
        if (contractCoin.symbol == SupportedTokens.HYN_RP_HRC30_ROPSTEN.symbol) {
          hynRPContractCoin = contractCoin;
        } else if (contractCoin.symbol == SupportedTokens.HYN_ERC20.symbol) {
          hynContractCoin = contractCoin;
        } else {
          coins.add(contractCoin);
        }
      }
    }
    if (hynContractCoin != null) {
      coins.add(hynContractCoin);
    }
    if (hynRPContractCoin != null) {
      coins.add(hynRPContractCoin);
    }
    return WalletVo(wallet: wallet, coins: coins);
  }

  void _saveWalletVoBalanceToDisk(WalletVo vo) {
    List jsonList = List();
    vo.coins.map((item) => jsonList.add(item.toJson())).toList();
    var encoded = json.encode(jsonList);
    AppCache.saveValue(PrefsKey.walletBalance, encoded);
  }

  void _recoverBalanceFromDisk(WalletVo vo) async {
    var encoded = await AppCache.getValue(PrefsKey.walletBalance);
    if (encoded != null && encoded != '') {
      List decoded = json.decode(encoded);
      var deList = decoded.map((item) => CoinVo.fromJson(item)).toList();
      for (var cVo in vo.coins) {
        for (var dVO in deList) {
          if (cVo.symbol == dVO.symbol && cVo.contractAddress == dVO.contractAddress) {
            cVo.balance = dVO.balance;
            break;
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
    responseFromEthGasStationDict["fastest"] = min(fastGasPrice, fastest);

    // fast
    var proposeGasPrice = double.parse(responseFromEtherScanDict["ProposeGasPrice"]) * 10.0;
    var fast = double.parse(responseFromEthGasStationDict["fast"].toString());
    responseFromEthGasStationDict["fast"] = min(proposeGasPrice, fast);

    // average
    var safeGasPrice = double.parse(responseFromEtherScanDict["SafeGasPrice"]) * 10.0;
    var average = double.parse(responseFromEthGasStationDict["average"].toString());
    responseFromEthGasStationDict["average"] = min(safeGasPrice, average);

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
