import 'package:json_annotation/json_annotation.dart';

part 'coin_vo.g.dart';

@JsonSerializable()
class CoinVo {
  final String name;
  final String symbol;
  final String logo;
  final String address;
  final String contractAddress;
  final String extendedPublicKey;

  final int decimals;
  final int coinType;

  BigInt balance;

  CoinVo(
      {this.decimals,
      this.name,
      this.symbol,
      this.logo,
      this.address,
      this.contractAddress,
      this.extendedPublicKey,
      this.balance,
      this.coinType});

  factory CoinVo.fromJson(Map<String, dynamic> json) => _$CoinVoFromJson(json);

  Map<String, dynamic> toJson() => _$CoinVoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
