import 'package:flutter/widgets.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_core.dart';

class WalletUtil {
  static Future<String> makeMnemonic() {
    return WalletCore.makeMnemonic();
  }

  ///扫描所有钱包
  static Future<List<Wallet>> scanWallets() async {
    var wallets = <Wallet>[];

    var keyStoreMaps = await WalletCore.scanKeyStores();
    for (var map in keyStoreMaps) {
//      logger.i(map);
      var wallet = _parseWalletJson(map);
      if(wallet != null) {
        wallets.add(wallet);
      }
    }
    return wallets;
  }

  ///储存助记词
  static Future<Wallet> saveAsTrustWalletKeyStoreByMnemonic(
      {@required String name,
      @required String password,
      @required String mnemonic}) async {
    var fileName = await WalletCore.saveAsTrustWalletKeyStoreByMnemonic(
        name: name, mnemonic: mnemonic, password: password);
    return loadWallet(fileName);
  }

  ///储存私钥
  static Future<Wallet> saveAsTrustWalletKeyStoreByPrvKey(
      {@required String name,
      @required String password,
      @required String prvKeyHex}) async {
    var fileName = await WalletCore.saveAsTrustWalletKeyStoreByPrivateKey(
        name: name, prvKeyHex: prvKeyHex, password: password);
    return loadWallet(fileName);
  }

  ///储存KeyStore Json
  static Future<Wallet> saveAsTrustWalletKeyStoreByJson(
      {@required String name,
      @required String password,
      @required String keyStoreJson}) async {
    var fileName = await WalletCore.saveKeyStoreByJson(
        name: name, keyStoreJson: keyStoreJson, password: password);
    return loadWallet(fileName);
  }

  ///查看eth油费
  static Future<BigInt> ethGasPrice() {
    return WalletCore.ethGasPrice(isMainNet: WalletConfig.isMainNet);
  }

  ///加载单个钱包
  static Future<Wallet> loadWallet(String fileName) async {
    var map = await WalletCore.loadKeyStore(fileName);
    var wallet = _parseWalletJson(map);
    return wallet;
  }

  static Wallet _parseWalletJson(dynamic map) {
    if (map['type'] == KeyStoreType.TrustWallet.index) {
      var keystore = TrustWalletKeyStore.fromJson(map);
      var accounts = List<Account>.from(map['accounts'].map((accountMap) =>
          Account.fromJson(accountMap, WalletConfig.isMainNet)));
      var wallet = TrustWallet(keystore: keystore, accounts: accounts);
      return wallet;
    } else if (map['type'] == KeyStoreType.V3.index) {
      var keystore = V3KeyStore.fromJson(map);
      var account = Account.fromJson(map['account'], WalletConfig.isMainNet);
      var wallet = V3Wallet(keystore: keystore, account: account);
      return wallet;
    }
    return null;
  }
}
