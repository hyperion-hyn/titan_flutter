// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetail _$OrderDetailFromJson(Map<String, dynamic> json) {
  return OrderDetail(
    json['market'] as String,
    json["side"] as String,
    json['oid'] as String,
    json['price'] as String,
    json['amount'] as String,
    json['turnover'] as String,
    json['time'] as String,
    json['fee'] as String,
  );
}

Map<String, dynamic> _$OrderDetailToJson(OrderDetail instance) =>
    <String, dynamic>{
      'market': instance.market,
      'side': instance.side,
      'oid': instance.oid,
      'price': instance.price,
      'amount': instance.amount,
      'turnover': instance.turnover,
      'time': instance.time,
      'fee': instance.fee,
    };
