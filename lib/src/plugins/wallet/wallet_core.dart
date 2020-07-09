import 'package:flutter/widgets.dart';
import 'package:titan/src/plugins/titan_plugin.dart';

class WalletCore {
//  static Future<String> makeMnemonic() async {
//    return await TitanPlugin.callChannel.invokeMethod("wallet_make_mnemonic");
//  }

  static Future<String> saveAsTrustWalletKeyStoreByMnemonic({
    @required String name,
    @required String password,
    @required String mnemonic,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_import_mnemonic", {
      'name': name,
      'password': password,
      'mnemonic': mnemonic,
    });
  }

  static Future<String> saveAsTrustWalletKeyStoreByPrivateKey({
    @required String name,
    @required String password,
    @required String prvKeyHex,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_import_prvKey", {
      'name': name,
      'password': password,
      'prvKeyHex': prvKeyHex,
    });
  }

  static Future<String> saveKeyStoreByJson({
    @required String name,
    @required String password,
    @required String keyStoreJson,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_import_json", {
      'name': name,
      'password': password,
      'keyStoreJson': keyStoreJson,
    });
  }

  static Future<dynamic> loadKeyStore(String fileName) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_load_keystore", {"fileName": fileName});
  }

  static Future<dynamic> scanKeyStores() async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_all_keystore");
  }

  static Future<String> changeKeyStorePassword({
    @required String fileName,
    @required oldPassword,
    @required newPassword,
    name,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_change_password", {
      "fileName": fileName,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'name': name,
    });
  }

  static Future<String> exportPrivateKey({
    @required String fileName,
    @required password,
  }) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_getPrivateKey", {
      "fileName": fileName,
      'password': password,
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

  ///delete wallet
  static Future<bool> delete(String fileName) async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_delete", {"fileName": fileName});
  }
}