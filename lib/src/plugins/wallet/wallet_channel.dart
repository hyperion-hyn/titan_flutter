import 'package:flutter/widgets.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';

class WalletChannel {
//  static Future<String> makeMnemonic() async {
//    return await TitanPlugin.callChannel.invokeMethod("wallet_make_mnemonic");
//  }

  static Future<String> saveAsTrustWalletKeyStoreByMnemonic({
    @required String name,
    @required String password,
    @required String mnemonic,
    List<int> activeCoins = const [CoinType.ETHEREUM, CoinType.BITCOIN],
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_import_mnemonic", {
      'name': name,
      'password': password,
      'mnemonic': mnemonic,
      'activeCoins': activeCoins,
    });
  }

  static Future<String> saveAsTrustWalletKeyStoreByPrivateKey({
    @required String name,
    @required String password,
    @required String prvKeyHex,
    int coinTypeValue = CoinType.ETHEREUM,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_import_prvKey", {
      'name': name,
      'password': password,
      'prvKeyHex': prvKeyHex,
      'coinTypeValue': coinTypeValue,
    });
  }

  static Future<String> saveKeyStoreByJson({
    @required String name,
    @required String password,
    @required String newPassword,
    @required String keyStoreJson,
    List<int> activeCoins = const [CoinType.ETHEREUM, CoinType.BITCOIN],
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_import_json", {
      'name': name,
      'password': password,
      'newPassword': newPassword,
      'keyStoreJson': keyStoreJson,
      'activeCoins': activeCoins,
    });
  }

  static Future<dynamic> loadKeyStore(String fileName) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_load_keystore", {"fileName": fileName});
  }

  static Future<dynamic> scanKeyStores() async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_all_keystore");
  }

  static Future<String> updateWallet({
    @required String fileName,
    @required oldPassword,
    @required newPassword,
    name,
    List<int> activeCoins = const [CoinType.ETHEREUM, CoinType.BITCOIN],
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_update", {
      "fileName": fileName,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'name': name,
      'activeCoins': activeCoins,
    });
  }

  static Future<String> exportPrivateKey({
    @required String fileName,
    @required password,
    int coinTypeValue = CoinType.ETHEREUM,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_getPrivateKey", {
      "fileName": fileName,
      'password': password,
      'coinTypeValue': coinTypeValue,
    });
  }

  static Future<String> exportMnemonic({
    @required String fileName,
    @required password,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_getMnemonic", {
      "fileName": fileName,
      'password': password,
    });
  }

  ///删除钱包
  static Future<bool> delete(String fileName, String password, [int coinTypeValue = CoinType.ETHEREUM]) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_delete", {
      "fileName": fileName,
      "password": password,
      "coinTypeValue": coinTypeValue,
    });
  }

  static Future<String> signPersonalMessage(
    String fileName, String password, String personalMessage,
  ) async {
    return await TitanPlugin.callChannel.invokeMethod("signPersonalMessage", {
      "fileName": fileName,
      'password': password,
      'message': personalMessage,
    });
  }

  static Future<String> signTypeMessage(
      String fileName, String password, String typeMessage,
      ) async {
    print("[wallet_channel] typeMessage:$typeMessage");

    return await TitanPlugin.callChannel.invokeMethod("signTypeMessage", {
      "fileName": fileName,
      'password': password,
      'typeMessage': typeMessage,
    });
  }
}
