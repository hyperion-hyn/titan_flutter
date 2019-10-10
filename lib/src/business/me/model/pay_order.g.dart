// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayOrder _$PayOrderFromJson(Map<String, dynamic> json) {
  return PayOrder(
    json['address'] as String,
    json['amount'] as int,
    json['order_id'] as int,
    json['qr_code'] as String,
    json['state'] as int,
    json['hyn_amount'] as String,
  );
}

Map<String, dynamic> _$PayOrderToJson(PayOrder instance) => <String, dynamic>{
      'address': instance.address,
      'amount': instance.amount,
      'order_id': instance.order_id,
      'qr_code': instance.qr_code,
      'state': instance.state,
      'hyn_amount': instance.hyn_amount,
    };
