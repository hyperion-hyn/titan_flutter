import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

part 'wallet_account_vo.g.dart';

@JsonSerializable()
class WalletAccountVo {
  Wallet wallet;
  Account account;
  AssetToken assetToken;
  String name;
  double count;
  double currencyRate;
  double ethCurrencyRate;
  String currencyUnit;
  String currencyUnitSymbol;
  String symbol;
  double amount;

  WalletAccountVo(
      {this.wallet,
      this.account,
      this.assetToken,
      this.name,
      this.count = 0,
      this.currencyRate = 0,
      this.currencyUnit = "",
      this.currencyUnitSymbol = "\$",
      this.ethCurrencyRate = 0,
      this.symbol,
      this.amount = 0});

  factory WalletAccountVo.fromJson(Map<String, dynamic> json) => _$WalletAccountVoFromJson(json);

  Map<String, dynamic> toJson() => _$WalletAccountVoToJson(this);
}
