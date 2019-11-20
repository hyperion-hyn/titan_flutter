import 'package:flutter/widgets.dart';
import 'package:titan/src/plugins/titan_plugin.dart';

class WalletCore {
  static Future<String> makeMnemonic() async {
    return await TitanPlugin.callChannel.invokeMethod("wallet_make_mnemonic");
  }

  static Future<String> saveAsTrustWalletKeyStoreByMnemonic({
    @required String name,
    @required String password,
    @required String mnemonic,
  }) async {
    return await TitanPlugin.callChannel
        .invokeMethod("wallet_import_mnemonic", {
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
    return await TitanPlugin.callChannel
        .invokeMethod("wallet_load_keystore", {"fileName": fileName});
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
    return await TitanPlugin.callChannel
        .invokeMethod("wallet_change_password", {
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

  static Future<BigInt> getBalance({
    @required String address,
    @required int coinType,
    String erc20ContractAddress,
    bool isMainNet,
  }) async {
    var balanceHex =
        await TitanPlugin.callChannel.invokeMethod("wallet_getBalance", {
      "address": address,
      "coinType": coinType,
      "erc20ContractAddress": erc20ContractAddress,
      "isMainNet": isMainNet
    });
    return BigInt.parse(balanceHex, radix: 16);
  }

  static Future<BigInt> ethGasPrice({bool isMainNet}) async {
    var gasPriceStr = await TitanPlugin.callChannel
        .invokeMethod("wallet_ethGasPrice", {"isMainNet": isMainNet});
    return BigInt.parse(gasPriceStr, radix: 16);
  }

  ///删除钱包
  static Future<bool> delete(String fileName) async {
    return await TitanPlugin.callChannel
        .invokeMethod("wallet_delete", {"fileName": fileName});
  }

  ///计算费用
  static Future<BigInt> estimateGas({
    @required String fromAddress,
    @required String toAddress,
    @required int coinType,
    @required String amount,
    String erc20ContractAddress,
    bool isMainNet,
  }) async {
    var gasLimit =
        await TitanPlugin.callChannel.invokeMethod("wallet_estimateGas", {
      "fromAddress": fromAddress,
      "toAddress": toAddress,
      "coinType": coinType,
      "amount": amount,
      "erc20ContractAddress": erc20ContractAddress,
      "isMainNet": isMainNet,
    });
    return BigInt.parse(gasLimit, radix: 16);
  }

  static Future<String> transfer({
    @required String password,
    @required String fileName,
    @required String fromAddress,
    @required String toAddress,
    @required String amount,
    @required int coinType,
    String erc20ContractAddress,
    bool isMainNet,
    String data,
  }) async {
    var txHash = await TitanPlugin.callChannel.invokeMethod("wallet_transfer", {
      "password": password,
      "fileName": fileName,
      "fromAddress": fromAddress,
      "toAddress": toAddress,
      "amount": amount,
      "coinType": coinType,
      "erc20ContractAddress": erc20ContractAddress,
      "isMainNet": isMainNet,
      "data": data,
    });
    return txHash;
  }
}
