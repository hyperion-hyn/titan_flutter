import 'dart:ffi';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/coin_market_api.dart';
import 'package:titan/src/business/wallet/model_vo.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  static const String QUOTE_UNIT = "USD";

  CoinMarketApi _coinMarketApi = CoinMarketApi();

  @override
  WalletState get initialState => WalletEmptyState();

  @override
  Stream<WalletState> mapEventToState(WalletEvent event) async* {
    if (event is ScanWalletEvent) {
      yield* _scanWallet();
    }
  }

  Stream<WalletState> _scanWallet() async* {
    var wallets = await WalletUtil.scanWallets();
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      Wallet wallet = wallets[0];
      yield ShowWalletState(await _buildWalletVo(wallet));
    }
  }

  Future<WalletVo> _buildWalletVo(Wallet wallet) async {
    Account account;
    if (wallet is TrustWallet) {
      account = wallet.getEthAccount();
    } else if (wallet is V3Wallet) {
      account = wallet.account;
    }

    if (account == null) {
      return null;
    }

    List<WalletAccountVo> walletAccountList = [];

    walletAccountList.add(await _buildMainTokenAccountVo(wallet, account, account.token));

    for (var token in account.erc20AssetTokens) {
      walletAccountList.add(await _buildErc20TokenAccountVo(wallet, account, token));
    }

    await _buildPrice(walletAccountList);

    var amount = 0.0;

    walletAccountList.forEach((element) {
      amount += element.amount;
    });

    WalletVo walletVo =
        WalletVo(wallet: wallet, amount: amount, amountUnit: QUOTE_UNIT, accountList: walletAccountList);
    return walletVo;
  }

  Future<WalletAccountVo> _buildMainTokenAccountVo(Wallet wallet, Account account, AssetToken token) async {
    var balance = await wallet.getBalance(account);

    WalletAccountVo walletAccountVo = WalletAccountVo(
        account: account,
        assetToken: token,
        name: token.name,
        shortName: "",
        count: balance / BigInt.from(pow(10, token.decimals)),
        symbol: token.symbol);
    return walletAccountVo;
  }

  Future<WalletAccountVo> _buildErc20TokenAccountVo(Wallet wallet, Account account, AssetToken token) async {
    var balance = await wallet.getErc20Balance(token.erc20ContractAddress);

    WalletAccountVo walletAccountVo = WalletAccountVo(
        account: account,
        assetToken: token,
        name: token.name,
        shortName: "",
        count: balance / BigInt.from(pow(10, token.decimals)),
        symbol: token.symbol);
    return walletAccountVo;
  }

  _buildPrice(List<WalletAccountVo> accountList) async {
    var symbolList = accountList.map((accountVo) {
      return accountVo.symbol;
    }).toList();

    var priceMap = await _getPriceFromApi(symbolList);

    for (var accountVo in accountList) {
      var price = priceMap[accountVo.symbol];
      accountVo.price = price;
      accountVo.priceUnit = QUOTE_UNIT;
      accountVo.amount = price * accountVo.count;
    }
  }

  Future<Map<String, double>> _getPriceFromApi(List<String> symbols) async {
    return _coinMarketApi.quotes(symbols, QUOTE_UNIT);
  }
}
