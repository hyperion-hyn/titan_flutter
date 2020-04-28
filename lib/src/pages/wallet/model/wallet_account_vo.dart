import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

part 'wallet_account_vo.g.dart';

@JsonSerializable()
class WalletAccountVo {
  Account account;
  AssetToken assetToken;
  double balance;

  WalletAccountVo({
    this.account,
    this.assetToken,
    this.balance = 0,
  });

  factory WalletAccountVo.fromJson(Map<String, dynamic> json) => _$WalletAccountVoFromJson(json);

  Map<String, dynamic> toJson() => _$WalletAccountVoToJson(this);
}
