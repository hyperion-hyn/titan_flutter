import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class AssetToken {
  final int decimals;
  final String name;
  final String symbol;
  final String logo;
  final String contractAddress;
  final bool hideable;

  const AssetToken({
    this.name,
    this.decimals,
    this.contractAddress,
    this.symbol,
    this.logo,
    this.hideable,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  factory AssetToken.fromJson(Map<String, dynamic> json) => _$AssetTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTokenToJson(this);
}
