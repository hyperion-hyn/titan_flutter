import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'vo/coin_vo.dart';
import 'vo/wallet_vo.dart';

class WalletRepository {
  Future updateWalletVoBalance(WalletVo walletVo) {
    return Future.wait(walletVo.coins.map((coin) => updateCoinBalance(walletVo.wallet, coin)).toList());
  }

  Future updateCoinBalance(Wallet wallet, CoinVo coin) async {
    var balance = await wallet.getBalanceByCoinTypeAndAddress(coin.coinType, coin.address, coin.contractAddress);
    coin.balance = (Decimal.parse(balance.toString()) / Decimal.parse(pow(10, coin.decimals).toString())).toDouble();
  }

  Future<Wallet> getLocalDiskWallet() async {
    var keystoreFileName = await getDefaultWalletFileName();
    if (keystoreFileName != null) {
      return await WalletUtil.loadWallet(keystoreFileName);
    }
    return null;
  }

  ///
  /// save the wallet file name of wallet to local dist
  ///
  Future saveDefaultWalletFileName(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (fileName == null) {
      await prefs.remove(PrefsKey.DEFAULT_WALLET_FILE_NAME);
    } else {
      await prefs.setString(PrefsKey.DEFAULT_WALLET_FILE_NAME, fileName);
    }
  }

  ///
  /// load default wallet from local dist
  ///
  Future<String> getDefaultWalletFileName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKey.DEFAULT_WALLET_FILE_NAME);
  }
}
