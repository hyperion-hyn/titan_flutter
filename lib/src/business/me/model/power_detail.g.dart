// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'power_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PowerDetail _$PowerDetailFromJson(Map<String, dynamic> json) {
  return PowerDetail(
    json['contract_id'] as int,
    json['order_id'] as int,
    json['power'] as int,
    (json['amount'] as num)?.toDouble(),
    (json['month_inc'] as num)?.toDouble(),
    json['pay_type'] as String,
    json['expired_at'] as int,
    json['expire'] as bool,
    json['created_at'] as int,
  );
}

Map<String, dynamic> _$PowerDetailToJson(PowerDetail instance) =>
    <String, dynamic>{
      'contract_id': instance.contractId,
      'order_id': instance.orderId,
      'power': instance.power,
      'amount': instance.amount,
      'month_inc': instance.monthInc,
      'pay_type': instance.payType,
      'expired_at': instance.expiredAt,
      'expire': instance.expire,
      'created_at': instance.createdAt,
    };
