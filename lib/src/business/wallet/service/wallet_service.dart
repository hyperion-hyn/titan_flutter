import 'dart:math';

import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

import '../coin_market_api.dart';
import '../model/wallet_account_vo.dart';
import '../model/wallet_vo.dart';

class WalletService {
  CoinMarketApi _coinMarketApi = CoinMarketApi();

  ///
  /// 构建walleto
  ///
  Future<WalletVo> buildWalletVo(Wallet wallet) async {
    Account account;
    if (wallet is Wallet) {
      account = wallet.getEthAccount();
    }

    if (account == null) {
      return null;
    }

    List<WalletAccountVo> walletAccountList = [];

    walletAccountList.add(await buildMainTokenAccountVo(wallet, account, account.token));

    for (var token in account.erc20AssetTokens) {
      walletAccountList.add(await buildErc20TokenAccountVo(wallet, account, token));
    }

    WalletVo walletVo = WalletVo(wallet: wallet, amount: 0, amountUnit: QUOTE_UNIT, accountList: walletAccountList);
    return walletVo;
  }

  ///
  /// 获取wallet的balance
  ///
  Future updateWalletVoBalace(WalletVo walletVo) async {
    List<WalletAccountVo> accountList = walletVo.accountList;

    for (var accountVoTemp in accountList) {
      await updateAccountBalance(accountVoTemp, walletVo.wallet);
    }
  }

  ///
  /// 获取account的balance
  ///
  Future updateAccountBalance(WalletAccountVo accountVo, Wallet wallet) async {
    if (accountVo.assetToken.erc20ContractAddress == null) {
      var balance = await wallet.getBalance(accountVo.account);
      accountVo.balance = balance / BigInt.from(pow(10, accountVo.assetToken.decimals));
    } else {
      var balance = await wallet.getErc20Balance(accountVo.assetToken.erc20ContractAddress);
      accountVo.balance = balance / BigInt.from(pow(10, accountVo.assetToken.decimals));
    }
  }

  ///
  ///
  /// 计算wallet的总价格
  Future<WalletVo> updateWalletVoPrice(WalletVo walletVo) async {
    await updateAccountListPrice(walletVo.accountList);

    var amount = 0.0;

    walletVo.accountList.forEach((element) {
      amount += element.amount;
    });

    walletVo.amount = amount;
    return walletVo;
  }

  ///
  /// 构建 eth account
  Future<WalletAccountVo> buildMainTokenAccountVo(Wallet wallet, Account account, AssetToken token) async {
    WalletAccountVo walletAccountVo = WalletAccountVo(
        wallet: wallet, account: account, assetToken: token, name: token.name, balance: 0, symbol: token.symbol);
    return walletAccountVo;
  }

  ///
  /// 构建erc20 account

  Future<WalletAccountVo> buildErc20TokenAccountVo(Wallet wallet, Account account, AssetToken token) async {
    WalletAccountVo walletAccountVo = WalletAccountVo(
        wallet: wallet, account: account, assetToken: token, name: token.name, balance: 0, symbol: token.symbol);
    return walletAccountVo;
  }

  ///
  /// 构建wallet account list 的价格
  void updateAccountListPrice(List<WalletAccountVo> accountList) async {
    var symbolList = accountList.map((accountVo) {
      return accountVo.symbol;
    }).toList();

    var priceMap = await getPriceFromApi(symbolList);

    for (var accountVo in accountList) {
      var price = priceMap[accountVo.symbol];
      accountVo.currencyRate = price;
      accountVo.ethCurrencyRate = priceMap["ETH"];
      accountVo.currencyUnit = QUOTE_UNIT;
      accountVo.amount = price * accountVo.balance;
    }
  }

  ///
  /// 构建account 的价格
  Future<WalletAccountVo> updateAccountPrice(WalletAccountVo accountVo) async {
    var symbolList = [accountVo.symbol];

    var priceMap = await getPriceFromApi(symbolList);

    var price = priceMap[accountVo.symbol];
    accountVo.currencyRate = price;
    accountVo.ethCurrencyRate = priceMap["ETH"];
    accountVo.currencyUnit = QUOTE_UNIT;
    accountVo.amount = price * accountVo.balance;
    return accountVo;
  }

  ///
  /// 更新单个account的价格
  Future updateAccountVo(WalletAccountVo accountVo) async {
    await updateAccountBalance(accountVo, accountVo.wallet);
    await updateAccountPrice(accountVo);
  }

  ///
  /// 从服务器中获取价格
  Future<Map<String, double>> getPriceFromApi(List<String> symbols) async {
    return _coinMarketApi.quotes(symbols, QUOTE_UNIT);
  }
}
