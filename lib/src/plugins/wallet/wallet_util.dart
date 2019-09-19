import 'package:flutter/widgets.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
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
      if (wallet != null) {
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

  ///计算费用
  static Future<BigInt> estimateGas({
    @required String fromAddress,
    @required String toAddress,
    @required int coinType,
    @required String amount,
    String erc20ContractAddress,
  }) {
    return WalletCore.estimateGas(
      fromAddress: fromAddress,
      toAddress: toAddress,
      coinType: coinType,
      amount: amount,
      erc20ContractAddress: erc20ContractAddress,
      isMainNet: WalletConfig.isMainNet,
    );
  }

  static Future<String> transfer({
    @required String password,
    @required String fileName,
    @required String fromAddress,
    @required String toAddress,
    @required String amount,
    @required int coinType,
    String isMainNet,
    String data,
  }) {
    return WalletCore.transfer(
      password: password,
      fileName: fileName,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      coinType: coinType,
      isMainNet: isMainNet,
      data: data,
    );
  }

  static Future<String> transferErc20Token({
    @required String password,
    @required String fileName,
    @required String fromAddress,
    @required String toAddress,
    @required String amount,
    @required String erc20ContractAddress,
    String isMainNet,
    String data,
  }) {
    return WalletCore.transfer(
      password: password,
      fileName: fileName,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      coinType: CoinType.ETHEREUM,
      erc20ContractAddress: erc20ContractAddress,
      isMainNet: isMainNet,
      data: data,
    );
  }

  static Future<String> exportPrivateKey({
    @required String fileName,
    @required password,
  }) {
    return WalletCore.exportPrivateKey(fileName: fileName, password: password);
  }

  static Future<String> exportMnemonic({
    @required String fileName,
    @required password,
  }) {
    return WalletCore.exportMnemonic(fileName: fileName, password: password);
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
