import 'dart:convert';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

import '../coin_market_api.dart';
import '../model/wallet_account_vo.dart';
import '../model/wallet_vo.dart';

class WalletService {
  static const String DEFAULT_WALLET_FILE_NAME = "default_wallet_file_name";
  static const String DEFAULT_WALLET_VO = "default_wallet_vo";

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
      accountVo.balance =
          (Decimal.parse(balance.toString()) / Decimal.fromInt(pow(10, accountVo.assetToken.decimals))).toDouble();
    } else {
      var balance = await wallet.getErc20Balance(accountVo.assetToken.erc20ContractAddress);
      accountVo.balance =
          (Decimal.parse(balance.toString()) / Decimal.fromInt(pow(10, accountVo.assetToken.decimals))).toDouble();
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
      accountVo.currencyUnitSymbol = QUOTE_UNIT_SYMBOL;
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
    accountVo.currencyUnitSymbol = QUOTE_UNIT_SYMBOL;
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
    if (!symbols.contains("ETH")) {
      symbols.add("ETH");
    }
    return _coinMarketApi.quotes(symbols, QUOTE_UNIT);
  }

  ///
  /// 保存默认的wallet 的filename
  ///
  Future saveDefaultWalletFileName(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (fileName == null) {
      await prefs.remove(DEFAULT_WALLET_FILE_NAME);
    } else {
      await prefs.setString(DEFAULT_WALLET_FILE_NAME, fileName);
    }
  }

  ///
  /// 获取默认的wallet的filename
  ///
  Future<String> getDefaultWalletFileName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString(DEFAULT_WALLET_FILE_NAME);
  }

  Future<bool> isDefaultWallet(Wallet wallet) async {
    String defaultWalletFileName = await getDefaultWalletFileName();
    String walletFileName = wallet.keystore.fileName;
    return defaultWalletFileName == walletFileName;
  }

  Future<WalletVo> getDefaultWalletVo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String walletVoJson = await prefs.getString(DEFAULT_WALLET_VO);
    logger.i("walletVoJson:${walletVoJson}");
    if (walletVoJson == null) {
      return null;
    } else {
      return WalletVo.fromJson(json.decode(walletVoJson));
    }
  }

  Future saveDefaultWalletVo(WalletVo walletVo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (walletVo == null) {
      await prefs.remove(DEFAULT_WALLET_VO);
    } else {
      await prefs.setString(DEFAULT_WALLET_VO, json.encode(walletVo.toJson()));
    }
  }
}
