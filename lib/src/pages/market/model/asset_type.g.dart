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
    json['withdraw_fee_by_gas'] as String,
    json['recharge'] as bool,
    json['withdraw'] as bool,
    json['recharge_min'] as String,
    json['withdraw_min'] as String,
    json['withdraw_max'] as String,
    json['exchange_available'] as String,
    json['exchange_freeze'] as String,
    json['btc'] as String,
    json['eth'] as String,
    json['hyn'] as String,
    json['usdt'] as String,
    json['usd'] as String,
    json['cny'] as String,
  );
}

Map<String, dynamic> _$AssetTypeToJson(AssetType instance) => <String, dynamic>{
      'account_available': instance.accountAvailable,
      'account_freeze': instance.accountFreeze,
      'withdraw_fee': instance.withdrawFee,
      'withdraw_fee_by_gas': instance.withdrawFeeByGas,
      'recharge': instance.recharge,
      'withdraw': instance.withdraw,
      'recharge_min': instance.rechargeMin,
      'withdraw_min': instance.withdrawMin,
      'withdraw_max': instance.withdrawMax,
      'exchange_available': instance.exchangeAvailable,
      'exchange_freeze': instance.exchangeFreeze,
      'btc': instance.btc,
      'eth': instance.eth,
      'hyn': instance.hyn,
      'usdt': instance.usdt,
      'usd': instance.usd,
      'cny': instance.cny,
    };
