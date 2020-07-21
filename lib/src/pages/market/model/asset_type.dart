import 'package:json_annotation/json_annotation.dart';

part 'asset_type.g.dart';

@JsonSerializable()
class AssetType extends Object {
  @JsonKey(name: 'account_available')
  String accountAvailable;

  @JsonKey(name: 'withdraw_fee')
  String withdrawFee;

  @JsonKey(name: 'recharge')
  bool recharge;

  @JsonKey(name: 'withdraw')
  bool withdraw;

  @JsonKey(name: 'exchange_available')
  String exchangeAvailable;

  @JsonKey(name: 'exchange_freeze')
  String exchangeFreeze;

  @JsonKey(name: 'btc')
  String btc;

  AssetType(
    this.accountAvailable,
    this.withdrawFee,
    this.recharge,
    this.withdraw,
    this.exchangeAvailable,
    this.exchangeFreeze,
    this.btc,
  );

  factory AssetType.fromJson(Map<String, dynamic> srcJson) =>
      _$AssetTypeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AssetTypeToJson(this);
}
