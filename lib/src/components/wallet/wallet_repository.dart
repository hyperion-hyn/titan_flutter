import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/log_util.dart';

import 'vo/coin_view_vo.dart';
import 'vo/wallet_view_vo.dart';

class WalletRepository {
  Future updateWalletVoBalance(WalletViewVo walletVo, [String symbol]) {
    return Future.wait(walletVo.coins
        .where((coin) => symbol == null || coin.symbol == symbol)
        .map((coin) => safeUpdateCoinBalance(walletVo.wallet, coin))
        .toList());
  }

  Future safeUpdateCoinBalance(Wallet wallet, CoinViewVo coin) async {
    var balance = coin.balance ?? BigInt.zero;
    try {
      coin.refreshStatus = Status.loading;
      if (coin.coinType == CoinType.BITCOIN) {
        balance = await wallet.getBitcoinBalance(wallet.getBitcoinZPub());
      } else {
        balance = await wallet.getBalanceByCoinTypeAndAddress(
            coin.coinType, coin.address, coin.contractAddress);
      }
      coin.refreshStatus = Status.success;
    } catch (e) {
      LogUtil.uploadException(e, 'balance update error');
      coin.refreshStatus = Status.failed;
    }
    coin.balance = balance;
//    coin.balance = (Decimal.parse(balance.toString()) / Decimal.parse(pow(10, coin.decimals).toString())).toDouble();
  }

  Future<Wallet> getActivatedWalletFormLocalDisk() async {
    var keystoreFileName = await getActivatedWalletFileName();
    if (keystoreFileName != null) {
      return await WalletUtil.loadWallet(keystoreFileName);
    }
    return null;
  }

  ///
  /// save the wallet file name of wallet to local dist
  ///
  Future saveActivatedWalletFileName(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (fileName == null) {
      await prefs.remove(PrefsKey.ACTIVATED_WALLET_FILE_NAME);
    } else {
      await prefs.setString(PrefsKey.ACTIVATED_WALLET_FILE_NAME, fileName);
    }
  }

  ///
  /// load activated wallet from local dist
  ///
  Future<String> getActivatedWalletFileName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKey.ACTIVATED_WALLET_FILE_NAME);
  }

  /// 加载本地法币计价
  Future<LegalSign> recoverLegalSign() async {
    var legalSignStr = await AppCache.getValue<String>(PrefsKey.SETTING_LEGAL_SIGN);
    if (legalSignStr != null && legalSignStr != '') {
      return LegalSign.fromJson(json.decode(legalSignStr));
    }
    return SupportedLegal.usd;
  }

  /// 保存法币计价
  Future<bool> saveLegalSign(LegalSign legalSign) async {
    var legalSignStr = json.encode(legalSign.toJson());
    return await AppCache.saveValue(PrefsKey.SETTING_LEGAL_SIGN, legalSignStr);
  }

  /// 保存行情价
  Future<bool> saveQuotePrice(QuotesModel quote) async {
    var str = json.encode(quote.toJson());
    return await AppCache.saveValue(PrefsKey.QUOTE_PRICE, str);
  }

  /// 还原本地行情价
  Future<QuotesModel> recoverQuotesModel() async {
    var str = await AppCache.getValue<String>(PrefsKey.QUOTE_PRICE);
    if (str != null && str != '') {
      return QuotesModel.fromJson(json.decode(str));
    }
    return null;
  }

  // /// 保存余额到本地
  // Future saveWalletVoBalanceToDisk(WalletViewVo vo) async {
  //   List coins = List();
  //   vo.coins.map((item) => coins.add(item.toJson())).toList();
  //   var coinsJson = json.encode(coins);
  //   await AppCache.saveValue(_getCoinsSaveKey(vo), coinsJson);
  // }
  //
  // /// 从本地恢复余额
  // void recoverBalanceFromDisk(WalletViewVo vo) async {
  //   var coinsJson = await AppCache.getValue(_getCoinsSaveKey(vo));
  //   if (coinsJson != null && coinsJson != '') {
  //     List coins = json.decode(coinsJson);
  //     var deCoinList = coins.map((item) => CoinViewVo.fromJson(item)).toList();
  //     for (var cVo in vo.coins) {
  //       for (var dVO in deCoinList) {
  //         if (cVo.symbol == dVO.symbol && cVo.contractAddress == dVO.contractAddress) {
  //           cVo.balance = dVO.balance;
  //           break;
  //         }
  //       }
  //     }
  //   }
  // }

  String _getCoinsSaveKey(WalletViewVo vo) {
    var ethAddress = vo.wallet.getEthAccount()?.address;
    return PrefsKey.walletBalance + '-${ethAddress ?? ''}';
  }

  /// fill activated coin view vo data
  // Future<WalletViewVo> fillActivatedCoinsViewVo(Wallet wallet) async {
  //   return loadActivatedWalletViewVo(wallet);
  // }

  String _getActivatedWalletViewVo(String identify) {
    return PrefsKey.ACTIVATED_WALLET_VIEW_VO + '-${identify ?? ''}';
  }

  Future<bool> saveWalletViewVo(WalletViewVo walletVo) async {
    String identify = walletVo?.wallet?.getEthAccount()?.address;
    var key = _getActivatedWalletViewVo(identify);
    var jsonStr = json.encode(walletVo.toJson());
    return AppCache.saveValue(key, jsonStr);
  }

  Future<bool> deleteWalletViewVo(WalletViewVo walletVo) async {
    String identify = walletVo?.wallet?.getEthAccount()?.address;
    var key = _getActivatedWalletViewVo(identify);
    return AppCache.remove(key);
  }

  Future<WalletViewVo> loadActivatedWalletViewVo(Wallet wallet) async {
    String identify = wallet?.getEthAccount()?.address;
    var key = _getActivatedWalletViewVo(identify);
    var jsonStr = await AppCache.getValue(key);
    if (jsonStr != null && jsonStr != '') {
      var localVo = WalletViewVo.fromJson(json.decode(jsonStr));
      localVo.wallet = wallet;
      return localVo;
    } else {
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
        var defaultVos = Tokens.defaultContractTokensByCoinType(account.coinType);
        for (var asset in defaultVos) {
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
      return WalletViewVo(wallet: wallet, coins: coins, balance: 0);
    }
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
}
