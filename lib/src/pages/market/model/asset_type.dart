import 'package:json_annotation/json_annotation.dart';

part 'asset_type.g.dart';

@JsonSerializable()
class AssetType extends Object {
  @JsonKey(name: 'account_available')
  String accountAvailable;

  @JsonKey(name: 'account_freeze')
  String accountFreeze;

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

  @JsonKey(name: 'eth')
  String eth;

  @JsonKey(name: 'usd')
  String usd;

  @JsonKey(name: 'cny')
  String cny;

  AssetType(
    this.accountAvailable,
    this.accountFreeze,
    this.withdrawFee,
    this.recharge,
    this.withdraw,
    this.exchangeAvailable,
    this.exchangeFreeze,
    this.btc,
    this.eth,
    this.usd,
    this.cny,
  );

  factory AssetType.fromJson(Map<String, dynamic> srcJson) =>
      _$AssetTypeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AssetTypeToJson(this);
}
