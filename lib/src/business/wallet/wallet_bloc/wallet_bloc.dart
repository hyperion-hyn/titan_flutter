import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:titan/src/business/wallet/coin_market_api.dart';
import 'package:titan/src/business/wallet/model/wallet_account_vo.dart';
import 'package:titan/src/business/wallet/model/wallet_vo.dart';
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
    yield ScanWalletLoadingState();
    var wallets = await WalletUtil.scanWallets();
    print("wallets is ${wallets.length}");
    if (wallets.length == 0) {
      yield WalletEmptyState();
    } else {
      Wallet wallet = wallets[0];
      var walletVo = await _buildWalletVo(wallet);
      yield ShowWalletState(walletVo);
      yield ShowWalletState(await _buildWalletVoPrice(walletVo));
    }
  }

  Future<WalletVo> _buildWalletVo(Wallet wallet) async {
    Account account;
    if (wallet is Wallet) {
      account = wallet.getEthAccount();
    }

    if (account == null) {
      return null;
    }

    List<WalletAccountVo> walletAccountList = [];

    walletAccountList.add(await _buildMainTokenAccountVo(wallet, account, account.token));

    for (var token in account.erc20AssetTokens) {
      walletAccountList.add(await _buildErc20TokenAccountVo(wallet, account, token));
    }

    WalletVo walletVo = WalletVo(wallet: wallet, amount: 0, amountUnit: QUOTE_UNIT, accountList: walletAccountList);
    return walletVo;
  }

  Future<WalletVo> _buildWalletVoPrice(WalletVo walletVo) async {
    await _buildPrice(walletVo.accountList);

    var amount = 0.0;

    walletVo.accountList.forEach((element) {
      amount += element.amount;
    });

    walletVo.amount = amount;
    return walletVo;
  }

  Future<WalletAccountVo> _buildMainTokenAccountVo(Wallet wallet, Account account, AssetToken token) async {
    var balance = await wallet.getBalance(account);

    WalletAccountVo walletAccountVo = WalletAccountVo(
        wallet: wallet,
        account: account,
        assetToken: token,
        name: token.name,
        count: balance / BigInt.from(pow(10, token.decimals)),
        symbol: token.symbol);
    return walletAccountVo;
  }

  Future<WalletAccountVo> _buildErc20TokenAccountVo(Wallet wallet, Account account, AssetToken token) async {
    var balance = await wallet.getErc20Balance(token.erc20ContractAddress);

    WalletAccountVo walletAccountVo = WalletAccountVo(
        wallet: wallet,
        account: account,
        assetToken: token,
        name: token.name,
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
      accountVo.currencyRate = price;
      accountVo.ethCurrencyRate = priceMap["ETH"];
      accountVo.currencyUnit = QUOTE_UNIT;
      accountVo.amount = price * accountVo.count;
    }
  }

  Future<Map<String, double>> _getPriceFromApi(List<String> symbols) async {
    return _coinMarketApi.quotes(symbols, QUOTE_UNIT);
  }
}
