// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetail _$OrderDetailFromJson(Map<String, dynamic> json) {
  return OrderDetail(
    json["side"] as int,
    json['oid'] as String,
    json['price'] as double,
    json['amount'] as double,
    json['time'] as String,
    json['fee'] as double,
  );
}

Map<String, dynamic> _$OrderDetailToJson(OrderDetail instance) =>
    <String, dynamic>{
      'side': instance.side,
      'oid': instance.oid,
      'price': instance.price,
      'amount': instance.amount,
      'time': instance.time,
      'fee': instance.fee,
    };
