import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

part 'wallet_vo.g.dart';

@JsonSerializable()
class WalletVo {
  Wallet wallet;

  ///eth, hyn etc..  account list
  List<CoinVo> coins;

  double balance;

  WalletVo({this.wallet, this.coins});

  factory WalletVo.fromJson(Map<String, dynamic> json) => _$WalletVoFromJson(json);

  Map<String, dynamic> toJson() => _$WalletVoToJson(this);
}
