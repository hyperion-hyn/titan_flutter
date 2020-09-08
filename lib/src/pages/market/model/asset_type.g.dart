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
    json['recharge_min'] as String,
    json['withdraw_min'] as String,
    json['exchange_available'] as String,
    json['exchange_freeze'] as String,
    json['btc'] as String,
    json['eth'] as String,
    json['hyn'] as String,
    json['usd'] as String,
    json['cny'] as String,
  );
}

Map<String, dynamic> _$AssetTypeToJson(AssetType instance) => <String, dynamic>{
      'account_available': instance.accountAvailable,
      'account_freeze': instance.accountFreeze,
      'withdraw_fee': instance.withdrawFee,
      'recharge': instance.recharge,
      'withdraw': instance.withdraw,
      'recharge_min': instance.rechargeMin,
      'withdraw_min': instance.withdrawMin,
      'exchange_available': instance.exchangeAvailable,
      'exchange_freeze': instance.exchangeFreeze,
      'btc': instance.btc,
      'eth': instance.eth,
      'hyn': instance.hyn,
      'usd': instance.usd,
      'cny': instance.cny,
    };
