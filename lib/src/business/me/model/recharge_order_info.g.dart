// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recharge_order_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RechargeOrderInfo _$RechargeOrderInfoFromJson(Map<String, dynamic> json) {
  return RechargeOrderInfo(
    json['address'] as String,
    (json['amount'] as num)?.toDouble(),
    json['order_id'] as int,
    json['qr_code'] as String,
    json['state'] as int,
    json['hyn_amount'] as String,
  );
}

Map<String, dynamic> _$RechargeOrderInfoToJson(RechargeOrderInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'amount': instance.amount,
      'order_id': instance.orderId,
      'qr_code': instance.qrCode,
      'state': instance.state,
      'hyn_amount': instance.hynAmount,
    };
