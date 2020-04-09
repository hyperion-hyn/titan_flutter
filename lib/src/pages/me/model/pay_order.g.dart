// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayOrder _$PayOrderFromJson(Map<String, dynamic> json) {
  return PayOrder(
    address: json['address'] as String,
    amount: json['amount'] as int,
    order_id: json['order_id'] as int,
    qr_code: json['qr_code'] as String,
    state: json['state'] as int,
    hyn_amount: json['hyn_amount'] as String,
    erc20USDTAmount: (json['erc20USDTAmount'] as num)?.toDouble(),
    hynUSDTAmount: (json['hynUSDTAmount'] as num)?.toDouble(),
    is_free: json['is_free'] as int,
  );
}

Map<String, dynamic> _$PayOrderToJson(PayOrder instance) => <String, dynamic>{
      'address': instance.address,
      'amount': instance.amount,
      'order_id': instance.order_id,
      'qr_code': instance.qr_code,
      'state': instance.state,
      'hyn_amount': instance.hyn_amount,
      'is_free': instance.is_free,
      'erc20USDTAmount': instance.erc20USDTAmount,
      'hynUSDTAmount': instance.hynUSDTAmount,
    };
