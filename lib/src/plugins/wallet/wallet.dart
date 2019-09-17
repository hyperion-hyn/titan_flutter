import 'package:flutter/widgets.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet_core.dart';

enum WalletType { TrustWallet, V3 }

class WalletConfig {
  static bool isMainNet = true;
}

abstract class Wallet {
  KeyStore keystore;

  Wallet({this.keystore});

  ///获取账户余额
  Future<BigInt> getBalance(Account account) async {
    if (account != null) {
      var balance = await WalletCore.getBalance(
          address: account.address,
          coinType: account.coinType,
          isMainNet: WalletConfig.isMainNet);
      return balance;
    }
    return BigInt.from(0);
  }

  ///获取erc20账户余额
  Future<BigInt> getErc20Balance(String contractAddress);

  Future<bool> delete() async {
    return WalletCore.delete(keystore.fileName);
  }

//  Future<bool> changePassword({
//    @required String oldPassword,
//    @required String newPassword,
//    String name
//  }) async {
//    var isSuccess = await keystore.changePassword(oldPassword: oldPassword, newPassword: newPassword, name: name);
//    if(isSuccess) {
//      if(this is TrustWallet) {
//        (this as TrustWallet).
//      }
//    }
//  }
}

class TrustWallet extends Wallet {
  List<Account> accounts;

  TrustWallet({TrustWalletKeyStore keystore, this.accounts})
      : super(keystore: keystore);

  @override
  Future<BigInt> getErc20Balance(String contractAddress) async {
    var account = getEthAccount();
    if (account != null) {
      var balance = await WalletCore.getBalance(
          address: account.address,
          coinType: account.coinType,
          isMainNet: WalletConfig.isMainNet,
          erc20ContractAddress: contractAddress);
      return balance;
    }

    return BigInt.from(0);
  }

  Account getEthAccount() {
    for (var account in accounts) {
      if (account.coinType == CoinType.ETHEREUM) {
        return account;
      }
    }
    return null;
  }
}

///可以认为是eth专用钱包
class V3Wallet extends Wallet {
  Account account;

  V3Wallet({V3KeyStore keystore, this.account}) : super(keystore: keystore);

  @override
  Future<BigInt> getErc20Balance(String contractAddress) async {
    if (account != null && account.coinType == CoinType.ETHEREUM) {
      var balance = await WalletCore.getBalance(
          address: account.address,
          coinType: account.coinType,
          isMainNet: WalletConfig.isMainNet,
          erc20ContractAddress: contractAddress);
      return balance;
    }
    return BigInt.from(0);
  }
}

