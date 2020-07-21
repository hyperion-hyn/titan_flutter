// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetType _$AssetTypeFromJson(Map<String, dynamic> json) {
  return AssetType(
    json['account_available'] as String,
    json['account_freeze'] as String,
    json['withdraw_fee'] as String,
    json['recharge'] as bool,
    json['withdraw'] as bool,
    json['exchange_available'] as String,
    json['exchange_freeze'] as String,
    json['btc'] as String,
  );
}

Map<String, dynamic> _$AssetTypeToJson(AssetType instance) => <String, dynamic>{
  'account_available': instance.accountAvailable,
  'account_freeze': instance.accountFreeze,
  'withdraw_fee': instance.withdrawFee,
  'recharge': instance.recharge,
  'withdraw': instance.withdraw,
  'exchange_available': instance.exchangeAvailable,
  'exchange_freeze': instance.exchangeFreeze,
  'btc': instance.btc,
};
