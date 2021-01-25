import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/components/app_lock/app_lock_bloc.dart';
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
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/utils/future_util.dart';
import 'package:titan/src/utils/log_util.dart';

import 'bloc.dart';
import '../../../global.dart';
import '../wallet_repository.dart';
import '../vo/wallet_view_vo.dart';
import '../vo/coin_view_vo.dart';

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
  int _lastUpdateQuotesTime = 0;

  //fix wallet change stop
//  @override
//  Stream<Transition<WalletCmpEvent, WalletCmpState>> transformEvents(Stream<WalletCmpEvent> events, transitionFn) {
//    return events.switchMap(transitionFn);
//  }

  @override
  Stream<WalletCmpState> mapEventToState(WalletCmpEvent event) async* {
    // 激活钱包
    if (event is ActiveWalletEvent) {
      var isSameWallet = false;

      if (event.wallet == null) {
        _activatedWalletVo = null;
      } else {
        if (_activatedWalletVo?.wallet?.getEthAccount()?.address ==
            event.wallet.getEthAccount().address) {
          isSameWallet = true;
        }
        //wallet account token 转 viewModel
        _activatedWalletVo = walletToWalletCoinsVo(event.wallet);
      }

      if (event.wallet != null && !isSameWallet) {
        _lastUpdateBalanceTime = 0; //set can update balance in time.

        // 还原余额、扩展信息
        if (_activatedWalletVo != null) {
          await _recoverBalanceFromDisk(_activatedWalletVo);
          _activatedWalletVo.wallet.walletExpandInfoEntity =
              await WalletUtil.getWalletExpandInfo(event.wallet.getEthAccount().address) ??
                  WalletExpandInfoEntity.defaultEntity();
        }

        if (event.onlyActive != true) {
          walletRepository
              .saveActivatedWalletFileName(_activatedWalletVo?.wallet?.keystore?.fileName);

          //sync wallet account to server  BTC生成找零地址等这些
          if (event.wallet?.getBitcoinZPub()?.isNotEmpty ?? false) {
            BitcoinApi.syncBitcoinPubToServer(
                event.wallet.getBitcoinAccount().address, event.wallet?.getBitcoinZPub() ?? "");
          }
//        _nodeApi.postWallets(_activatedWalletVo);

          // 同步地址名称
          var userPayload = UserPayloadWithAddressEntity(
              Payload(userName: event?.wallet?.keystore?.name ?? ""),
              event?.wallet?.getAtlasAccount()?.address ?? "");
          AtlasApi.postUserSync(userPayload);
        }
      }

      yield ActivatedWalletState(walletVo: _activatedWalletVo?.copyWith());
    } else if (event is UpdateActivatedWalletBalanceEvent) {
      var nowTime = DateTime.now().millisecondsSinceEpoch;
      //10 second cache time
      bool isTimeExpired = nowTime - _lastUpdateBalanceTime > 10000;
      // if (_activatedWalletVo != null && isTimeExpired) {
      _lastUpdateBalanceTime = nowTime;

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
        _saveWalletVoBalanceToDisk(_activatedWalletVo);
        yield BalanceState(
            walletVo: _activatedWalletVo, status: Status.success, symbol: event.symbol);
      } catch (e) {
        LogUtil.uploadException(e, 'UpdateWalletBalance Error');
        yield BalanceState(
            walletVo: _activatedWalletVo, status: Status.failed, symbol: event.symbol);
      }
      // }
    } else if (event is LoadLocalDiskWalletAndActiveEvent) {
      // 恢复法币计价
      var legalSign = await _recoverLegalSign();
      if (legalSign != null) {
        yield LegalSignState(sign: legalSign);
      }

      var wallet = await walletRepository.getActivatedWalletFormLocalDisk();
      //now active loaded wallet. tips: maybe null
      add(ActiveWalletEvent(wallet: wallet, onlyActive: true));
    } else if (event is UpdateQuotesEvent) {
      var nowTime = DateTime.now().millisecondsSinceEpoch;
      // 30秒
      bool isTimeExpired = nowTime - _lastUpdateQuotesTime > 30000;
      // if (isTimeExpired) {
      yield QuotesState(status: Status.loading);

      try {
        var allLegal = SupportedLegal.all.map((legal) => legal.legal).toList();
        var quotes = await _coinMarketApi.quotesLatest(allLegal);
        yield QuotesState(status: Status.success, quotes: QuotesModel(quotes: quotes));
      } catch (e, stack) {
        LogUtil.uploadException("$e$stack", 'Update Quotes Error');
        yield QuotesState(status: Status.failed);
      }
      // }
    } else if (event is UpdateLegalSignEvent) {
      _saveLegalSign(event.legal);
      yield LegalSignState(sign: event.legal);
    } else if (event is UpdateGasPriceEvent) {
      yield GasPriceState(status: Status.loading, type: event.type);

      if (event.type == GasPriceType.ETH || event.type == null) {
        try {
          var response = await futureRetry(3, requestEthGasPrice);
          var gasPriceRecommend = GasPriceRecommend(
              parseGasPriceToBigIntWei(response['fastest']),
              0.5,
              parseGasPriceToBigIntWei(response['fast']),
              4,
              parseGasPriceToBigIntWei(response['average']),
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
                status: Status.success,
                btcGasPriceRecommend: btcGasPriceRecommend,
                type: event.type);
          }
        } catch (e) {
          var btcGasPriceEntityStr =
              await AppCache.getValue(PrefsKey.SHARED_PREF_BTC_GAS_PRICE_KEY);
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
  }

  /// 加载本地法币计价
  Future<LegalSign> _recoverLegalSign() async {
    var legalSignStr = await AppCache.getValue<String>(PrefsKey.SETTING_LEGAL_SIGN);
    if (legalSignStr != null && legalSignStr != '') {
      return LegalSign.fromJson(json.decode(legalSignStr));
    }
    return SupportedLegal.usd;
  }

  /// 保存法币计价
  Future<bool> _saveLegalSign(LegalSign legalSign) async {
    var legalSignStr = json.encode(legalSign.toJson());
    return await AppCache.saveValue(PrefsKey.SETTING_LEGAL_SIGN, legalSignStr);
  }

  /// flat wallet accounts
  WalletViewVo walletToWalletCoinsVo(Wallet wallet) {
    List<CoinViewVo> coins = [];
    for (var account in wallet.accounts) {
      // add public chain coin
      CoinViewVo coin = CoinViewVo(
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
        CoinViewVo contractCoin = CoinViewVo(
          name: asset.name,
          symbol: asset.symbol,
          coinType: account.coinType,
          address: account.address,
          decimals: asset.decimals,
          contractAddress: asset.contractAddress,
          logo: asset.logo,
          balance: BigInt.from(0),
        );
        coins.add(contractCoin);
      }
    }
    return WalletViewVo(wallet: wallet, coins: coins);
  }

  /// 保存余额到本地
  void _saveWalletVoBalanceToDisk(WalletViewVo vo) {
    List coins = List();
    vo.coins.map((item) => coins.add(item.toJson())).toList();
    var coinsJson = json.encode(coins);
    AppCache.saveValue(_getCoinsSaveKey(vo), coinsJson);
  }

  /// 从本地恢复余额
  Future _recoverBalanceFromDisk(WalletViewVo vo) async {
    var coinsJson = await AppCache.getValue(_getCoinsSaveKey(vo));
    if (coinsJson != null && coinsJson != '') {
      List coins = json.decode(coinsJson);
      var deCoinList = coins.map((item) => CoinViewVo.fromJson(item)).toList();
      for (var cVo in vo.coins) {
        for (var dVO in deCoinList) {
          if (cVo.symbol == dVO.symbol && cVo.contractAddress == dVO.contractAddress) {
            cVo.balance = dVO.balance;
            break;
          }
        }
      }
    }
  }

  String _getCoinsSaveKey(WalletViewVo vo) {
    var ethAddress = vo.wallet.getEthAccount()?.address;
    return PrefsKey.walletBalance + '-${ethAddress ?? ''}';
  }

  Future requestEthGasPrice() async {
    var responseFromEtherScan = await EtherscanApi().getGasFromEtherScan();
    var responseFromEtherScanDict = responseFromEtherScan.data as Map;

    // fastest
    var fastGasPrice = double.parse(responseFromEtherScanDict["FastGasPrice"]);
    responseFromEtherScanDict["fastest"] = fastGasPrice;
    // fast
    var proposeGasPrice = double.parse(responseFromEtherScanDict["ProposeGasPrice"]);
    responseFromEtherScanDict["fast"] = proposeGasPrice;
    // average
    var safeGasPrice = double.parse(responseFromEtherScanDict["SafeGasPrice"]);
    responseFromEtherScanDict["average"] = safeGasPrice;

    return responseFromEtherScanDict;
  }

  Future requestGasPriceOld() async {
    var responseFromEtherScan = await EtherscanApi().getGasFromEtherScan();
    var responseFromEthGasStation = await requestGasFromEthGasStation();
    //print("[object] requestGasPrice，1, responseFromEtherScan:$responseFromEtherScan, responseFromEthGasStation:$responseFromEthGasStation");

    var responseFromEtherScanDict = responseFromEtherScan.data as Map;
    var responseFromEthGasStationDict = responseFromEthGasStation as Map;

    // fastest
    var fastGasPrice = double.parse(responseFromEtherScanDict["FastGasPrice"]) * 10.0;
    var fastest = double.parse(responseFromEthGasStationDict["fastest"].toString());
    // responseFromEthGasStationDict["fastest"] = max(fastGasPrice, fastest);
    responseFromEthGasStationDict["fastest"] = (fastGasPrice + fastest) / 2;

    // fast
    var proposeGasPrice = double.parse(responseFromEtherScanDict["ProposeGasPrice"]) * 10.0;
    var fast = double.parse(responseFromEthGasStationDict["fast"].toString());
    // responseFromEthGasStationDict["fast"] = max(proposeGasPrice, fast);
    responseFromEthGasStationDict["fast"] = (proposeGasPrice + fast) / 2;

    // average
    var safeGasPrice = double.parse(responseFromEtherScanDict["SafeGasPrice"]) * 10.0;
    var average = double.parse(responseFromEthGasStationDict["average"].toString());
    // responseFromEthGasStationDict["average"] = max(safeGasPrice, average);
    responseFromEthGasStationDict["average"] = (safeGasPrice + average) / 2;

    //print("[object] requestGasPrice，2, responseFromEtherScanDict:$responseFromEtherScanDict, responseFromEthGasStationDict:$responseFromEthGasStationDict");

    return responseFromEthGasStationDict;
  }

  Future requestGasFromEthGasStation() async {
    var response = await HttpCore.instance.get('https://ethgasstation.info/json/ethgasAPI.json');
    return response;
  }

  Decimal parseGasPriceToBigIntWei(double num) {
    // return Decimal.parse(num.toString()) / Decimal.fromInt(10) * Decimal.fromInt(TokenUnit.G_WEI);
    return Decimal.parse(num.toString()) * Decimal.fromInt(EthereumUnitValue.G_WEI);
  }
}
