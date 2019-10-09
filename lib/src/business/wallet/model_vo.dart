import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class WalletAccountVo {
  TrustWallet wallet;
  Account account;
  AssetToken assetToken;
  String name;
  double count;
  double currencyRate;
  double ethCurrencyRate;
  String currencyUnit;
  String symbol;
  double amount;

  WalletAccountVo(
      {this.wallet,
      this.account,
      this.assetToken,
      this.name,
      this.count,
      this.currencyRate,
      this.currencyUnit,
      this.ethCurrencyRate,
      this.symbol,
      this.amount});
}

class WalletVo {
  TrustWallet wallet;
  double amount;
  String amountUnit;
  List<WalletAccountVo> accountList;

  WalletVo({this.wallet, this.amount, this.amountUnit, this.accountList});
}
