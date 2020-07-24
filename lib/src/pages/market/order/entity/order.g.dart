// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
    json['market'] as String,
    json['order_id'] as String,
    json['side'] as String,
    json['price'] as String,
    json['amount'] as String,
    json['ctime'] as String,
    json['status'] as String,
    json['amount_deal'] as String,
    json['amount_no_deal'] as String,
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'market': instance.market,
      'order_id': instance.orderId,
      'side': instance.side,
      'price': instance.price,
      'amount': instance.amount,
      'ctime': instance.ctime,
      'status': instance.status,
      'amount_deal': instance.amountDeal,
      'amount_no_deal': instance.amountNoDeal,
    };
