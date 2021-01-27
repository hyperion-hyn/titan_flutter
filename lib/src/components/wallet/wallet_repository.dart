import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
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
    }else{
      var walletList = await WalletUtil.scanWallets();
      if(walletList.length > 0){
        await saveActivatedWalletFileName(walletList[0].keystore.fileName);
        return walletList[0];
      }
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
}
