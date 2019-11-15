import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/business/wallet/model/wallet_account_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

part 'wallet_vo.g.dart';

@JsonSerializable()
class WalletVo {
  Wallet wallet;
  double amount;
  String amountUnit;
  List<WalletAccountVo> accountList;

  WalletVo({this.wallet, this.amount, this.amountUnit, this.accountList});

  factory WalletVo.fromJson(Map<String, dynamic> json) => _$WalletVoFromJson(json);

  Map<String, dynamic> toJson() => _$WalletVoToJson(this);
}
