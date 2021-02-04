import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/wallet_expand_info_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import '../coin_market_api.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/utils/future_util.dart';
import 'package:titan/src/utils/log_util.dart';

import 'bloc.dart';
import '../wallet_repository.dart';
import '../vo/wallet_view_vo.dart';

class WalletCmpBloc extends Bloc<WalletCmpEvent, WalletCmpState> {
  static const DEFAULT_SYMBOLS = ['ETH', 'HYN', 'USDT', 'BTC'];
  CoinMarketApi _coinMarketApi = CoinMarketApi();

  final WalletRepository walletRepository;

  WalletCmpBloc({@required this.walletRepository});

  WalletViewVo _activatedWalletVo;

  @override
  WalletCmpState get initialState => InitialWalletCmpState();

  NodeApi _nodeApi = NodeApi();

  int _lastUpdateBalanceTime = 0;
  bool _updatingBalance = false;
  int _lastUpdateQuotesTime = 0;

  //fix wallet change stop
//  @override
//  Stream<Transition<WalletCmpEvent, WalletCmpState>> transformEvents(Stream<WalletCmpEvent> events, transitionFn) {
//    return events.switchMap(transitionFn);
//  }

  @override
  Stream<WalletCmpState> mapEventToState(WalletCmpEvent event) async* {
    if (event is ActiveWalletEvent) {
      // 激活钱包
      yield* handleActivatedWallet(event);
    } else if (event is UpdateActivatedWalletBalanceEvent) {
      //更新余额
      yield* handleUpdateBalance(event);
    } else if (event is LoadLocalDiskWalletAndActiveEvent) {
      ///恢复本地钱包

      // 1、 恢复法币计价
      var legalSign = await walletRepository.recoverLegalSign();
      if (legalSign != null) {
        yield LegalSignState(sign: legalSign);
      }

      // 2、 恢复上次行情价格
      var quotes = await walletRepository.recoverQuotesModel();
      if (quotes != null) {
        yield QuotesState(quotes: quotes, status: Status.success);
      }

      // 3、 激活本地钱包
      var wallet = await walletRepository.getActivatedWalletFormLocalDisk();
      //now active loaded wallet. tips: maybe null
      if (wallet != null) {
        add(ActiveWalletEvent(wallet: wallet, onlyActive: true));
      }
    } else if (event is UpdateQuotesEvent) {
      // 更新行情价格
      yield* handleUpdateQuotePrice(event);
    } else if (event is UpdateLegalSignEvent) {
      // 设置法币计价
      walletRepository.saveLegalSign(event.legal);
      yield LegalSignState(sign: event.legal);
    } else if (event is UpdateGasPriceEvent) {
      // 更新当前矿工费用
      yield* handleUpdateGasPrice(event);
    } else if (event is UpdateWalletExpandEvent) {
      // 更新钱包配置信息
      await WalletUtil.setWalletExpandInfo(event.address, event.walletExpandInfoEntity);
      if (_activatedWalletVo != null &&
          _activatedWalletVo.wallet.getEthAccount().address == event.address) {
        _activatedWalletVo.wallet.walletExpandInfoEntity = event.walletExpandInfoEntity;
        yield UpdateWalletExpandState(event.walletExpandInfoEntity);
      }
    } else if (event is TurnOffTokensEvent) {
      // TODO
    } else if (event is TurnOnTokensEvent) {
      // TODO
    }
  }

  /// 更新行情价格
  Stream<WalletCmpState> handleUpdateQuotePrice(UpdateQuotesEvent event) async* {
    var nowTime = DateTime.now().millisecondsSinceEpoch;
    // 30秒
    bool isTimeExpired = nowTime - _lastUpdateQuotesTime > 30000;
    // if (isTimeExpired) {
    yield QuotesState(status: Status.loading);

    try {
      var allLegal = SupportedLegal.all.map((legal) => legal.legal).toList();
      var quotes = await _coinMarketApi.quotesLatest(allLegal);
      var quotesModel = QuotesModel(quotes: quotes);

      /// 保存本地
      walletRepository.saveQuotePrice(quotesModel);
      yield QuotesState(status: Status.success, quotes: quotesModel);
    } catch (e, stack) {
      LogUtil.uploadException("$e$stack", 'Update Quotes Error');
      yield QuotesState(status: Status.failed);
    }
    // }
  }

  /// 更新钱包账户余额
  Stream<WalletCmpState> handleUpdateBalance(UpdateActivatedWalletBalanceEvent event) async* {
    if (_activatedWalletVo != null) {
      if (_updatingBalance && event.symbol == null) {
        print('update balance in progress...');
        return;
      }

      var nowTime = DateTime.now().millisecondsSinceEpoch;
      //5 second cache time
      bool isTimeExpired = nowTime - _lastUpdateBalanceTime > 5000;
      if (event.symbol == null && !isTimeExpired) {
        print('update balance too often, ignore request');
        return;
      }
      if (event.symbol == null) {
        _updatingBalance = true;
      }

      for (var vo in _activatedWalletVo.coins) {
        if (event.symbol == null || event.symbol == vo.symbol) {
          vo.refreshStatus = Status.loading;
        }
      }
      yield BalanceState(
          walletVo: _activatedWalletVo, status: Status.loading, symbol: event.symbol);

      try {
        await walletRepository.updateWalletVoBalance(_activatedWalletVo, event.symbol);
        //save balance data to disk;
        walletRepository.saveWalletViewVo(_activatedWalletVo);
        yield BalanceState(
            walletVo: _activatedWalletVo, status: Status.success, symbol: event.symbol);

        if (event.symbol == null) {
          _lastUpdateBalanceTime = DateTime.now().millisecondsSinceEpoch;
        }
      } catch (e) {
        LogUtil.uploadException(e, 'UpdateWalletBalance Error');
        yield BalanceState(
            walletVo: _activatedWalletVo, status: Status.failed, symbol: event.symbol);
      }
      _updatingBalance = false;
    }
  }

  /// 激活/清除 当前活跃钱包
  Stream<WalletCmpState> handleActivatedWallet(ActiveWalletEvent event) async* {
    var isSameWallet = false;

    if (event.wallet == null) {
      if (_activatedWalletVo != null) {
        walletRepository.deleteWalletViewVo(_activatedWalletVo);
      }
      _activatedWalletVo = null;
    } else {
      if (_activatedWalletVo?.wallet?.getEthAccount()?.address ==
          event.wallet.getEthAccount().address) {
        isSameWallet = true;
      }
      // fill coin view vo data and balance
      _activatedWalletVo = await walletRepository.loadActivatedWalletViewVo(event.wallet);
    }

    if (event.wallet != null && !isSameWallet) {
      _lastUpdateBalanceTime = 0; //set can update balance in time.

      if (event.onlyActive != true) {
        walletRepository
            .saveActivatedWalletFileName(_activatedWalletVo?.wallet?.keystore?.fileName);

        //sync wallet account to server  BTC生成找零地址等这些
        if (event.wallet?.getBitcoinZPub()?.isNotEmpty ?? false) {
          BitcoinApi.syncBitcoinPubToServer(
              event.wallet.getBitcoinAccount().address, event.wallet?.getBitcoinZPub() ?? "");
        }

        // 同步地址名称
        var userPayload = UserPayloadWithAddressEntity(
            Payload(userName: event?.wallet?.keystore?.name ?? ""),
            event?.wallet?.getAtlasAccount()?.address ?? "");
        AtlasApi.postUserSync(userPayload);
      }
    }

    yield ActivatedWalletState(walletVo: _activatedWalletVo?.copyWith());
  }

  /// 更新gas 费用
  Stream<WalletCmpState> handleUpdateGasPrice(UpdateGasPriceEvent event) async* {
    yield GasPriceState(status: Status.loading, type: event.type);

    if (event.type == GasPriceType.ETH || event.type == null) {
      try {
        var response = await futureRetry(3, walletRepository.requestEthGasPrice);
        var gasPriceRecommend = GasPriceRecommend(
            _parseGasPriceToBigIntWei(response['fastest']),
            0.5,
            _parseGasPriceToBigIntWei(response['fast']),
            4,
            _parseGasPriceToBigIntWei(response['average']),
            15);

        await AppCache.saveValue(
            PrefsKey.SHARED_PREF_ETH_GAS_PRICE_KEY, json.encode(gasPriceRecommend.toJson()));
        yield GasPriceState(
            status: Status.success, ethGasPriceRecommend: gasPriceRecommend, type: event.type);
      } catch (e) {
        var gasPriceEntityStr = await AppCache.getValue(PrefsKey.SHARED_PREF_ETH_GAS_PRICE_KEY);
        if (gasPriceEntityStr != null && gasPriceEntityStr != '') {
          yield GasPriceState(
              status: Status.success,
              ethGasPriceRecommend: json.decode(gasPriceEntityStr),
              type: event.type);
        } else {
          yield GasPriceState(status: Status.failed, type: event.type);
        }
      }
    }
    if (event.type == GasPriceType.BTC || event.type == null) {
      try {
        var btcResponse = await BitcoinApi.requestBtcFeeRecommend();
        if (btcResponse["code"] == 0) {
          var btcResponseData = btcResponse["data"];
          var btcGasPriceRecommend = GasPriceRecommend(
              Decimal.fromInt(btcResponseData['fastest']),
              double.parse(btcResponseData['fastestWait'].toString()),
              Decimal.fromInt(btcResponseData['fast']),
              double.parse(btcResponseData['fastWait'].toString()),
              Decimal.fromInt(btcResponseData['average']),
              double.parse(btcResponseData['avgWait'].toString()));
          await AppCache.saveValue(
              PrefsKey.SHARED_PREF_BTC_GAS_PRICE_KEY, json.encode(btcGasPriceRecommend.toJson()));
          yield GasPriceState(
              status: Status.success, btcGasPriceRecommend: btcGasPriceRecommend, type: event.type);
        }
      } catch (e) {
        var btcGasPriceEntityStr = await AppCache.getValue(PrefsKey.SHARED_PREF_BTC_GAS_PRICE_KEY);
        if (btcGasPriceEntityStr != null) {
          yield GasPriceState(
              status: Status.success,
              btcGasPriceRecommend: json.decode(btcGasPriceEntityStr),
              type: event.type);
        } else {
          yield GasPriceState(status: Status.failed, type: event.type);
        }
      }
    }
  }

  // Future requestGasPriceOld() async {
  //   var responseFromEtherScan = await EtherscanApi().getGasFromEtherScan();
  //   var responseFromEthGasStation = await requestGasFromEthGasStation();
  //   //print("[object] requestGasPrice，1, responseFromEtherScan:$responseFromEtherScan, responseFromEthGasStation:$responseFromEthGasStation");
  //
  //   var responseFromEtherScanDict = responseFromEtherScan.data as Map;
  //   var responseFromEthGasStationDict = responseFromEthGasStation as Map;
  //
  //   // fastest
  //   var fastGasPrice = double.parse(responseFromEtherScanDict["FastGasPrice"]) * 10.0;
  //   var fastest = double.parse(responseFromEthGasStationDict["fastest"].toString());
  //   // responseFromEthGasStationDict["fastest"] = max(fastGasPrice, fastest);
  //   responseFromEthGasStationDict["fastest"] = (fastGasPrice + fastest) / 2;
  //
  //   // fast
  //   var proposeGasPrice = double.parse(responseFromEtherScanDict["ProposeGasPrice"]) * 10.0;
  //   var fast = double.parse(responseFromEthGasStationDict["fast"].toString());
  //   // responseFromEthGasStationDict["fast"] = max(proposeGasPrice, fast);
  //   responseFromEthGasStationDict["fast"] = (proposeGasPrice + fast) / 2;
  //
  //   // average
  //   var safeGasPrice = double.parse(responseFromEtherScanDict["SafeGasPrice"]) * 10.0;
  //   var average = double.parse(responseFromEthGasStationDict["average"].toString());
  //   // responseFromEthGasStationDict["average"] = max(safeGasPrice, average);
  //   responseFromEthGasStationDict["average"] = (safeGasPrice + average) / 2;
  //
  //   //print("[object] requestGasPrice，2, responseFromEtherScanDict:$responseFromEtherScanDict, responseFromEthGasStationDict:$responseFromEthGasStationDict");
  //
  //   return responseFromEthGasStationDict;
  // }
  //
  // Future requestGasFromEthGasStation() async {
  //   var response = await HttpCore.instance.get('https://ethgasstation.info/json/ethgasAPI.json');
  //   return response;
  // }

  Decimal _parseGasPriceToBigIntWei(double num) {
    // return Decimal.parse(num.toString()) / Decimal.fromInt(10) * Decimal.fromInt(TokenUnit.G_WEI);
    return Decimal.parse(num.toString()) * Decimal.fromInt(EthereumUnitValue.G_WEI);
  }
}
