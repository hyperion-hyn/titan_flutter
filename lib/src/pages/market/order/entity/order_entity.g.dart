// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderEntity _$OrderEntityFromJson(Map<String, dynamic> json) {
  return OrderEntity()
    ..id = json['id'] as String
    ..type = json['type'] as int
    ..state = json['state'] as int
    ..date = json['date'] as String
    ..symbol = json['symbol'] as String
    ..price = (json['price'] as num)?.toDouble()
    ..total = (json['total'] as num)?.toDouble()
    ..amount = (json['amount'] as num)?.toDouble()
    ..executed = (json['excuted'] as num)?.toDouble();
}

Map<String, dynamic> _$OrderEntityToJson(OrderEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'state': instance.state,
      'date': instance.date,
      'symbol': instance.symbol,
      'price': instance.price,
      'total': instance.total,
      'amount': instance.amount,
      'excuted': instance.executed,
    };
