// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseOrderInfo _$PurchaseOrderInfoFromJson(Map<String, dynamic> json) {
  return PurchaseOrderInfo(
    json['address'] as String,
    json['amount'] as int,
    json['order_id'] as int,
    json['qr_code'] as String,
    json['state'] as int,
    json['hyn_amount'] as String,
  );
}

Map<String, dynamic> _$PurchaseOrderInfoToJson(PurchaseOrderInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'amount': instance.amount,
      'order_id': instance.orderId,
      'qr_code': instance.qrCode,
      'state': instance.state,
      'hyn_amount': instance.hynAmount,
    };
