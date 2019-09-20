import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class WalletAccountVo {
  Account account;
  AssetToken accessToken;
  String name;
  String shortName;
  double count;
  double price;
  String priceUnit;
  String symbol;
  double amount;

  WalletAccountVo(
      {this.account,
      this.accessToken,
      this.name,
      this.shortName,
      this.count,
      this.price,
      this.priceUnit,
      this.symbol,
      this.amount});
}

class WalletVo {
  Wallet wallet;
  double amount;
  String amountUnit;
  List<WalletAccountVo> accountList;

  WalletVo({this.wallet, this.amount, this.amountUnit, this.accountList});
}
