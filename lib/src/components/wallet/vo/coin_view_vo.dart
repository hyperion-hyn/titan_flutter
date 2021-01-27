import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/config/consts.dart';

part 'coin_view_vo.g.dart';

@JsonSerializable()
class CoinViewVo {
  final String name;
  final String symbol;
  final String logo;
  final String address;
  final String contractAddress;
  final String extendedPublicKey;

  final int decimals;
  final int coinType;

  BigInt balance;

  //余额是否刷新成功
  Status refreshStatus;

  CoinViewVo(
      {this.decimals,
      this.name,
      this.symbol,
      this.logo,
      this.address,
      this.contractAddress,
      this.extendedPublicKey,
      this.balance,
      this.coinType,
      this.refreshStatus});

  factory CoinViewVo.fromJson(Map<String, dynamic> json) => _$CoinViewVoFromJson(json);

  Map<String, dynamic> toJson() => _$CoinViewVoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
