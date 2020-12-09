// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_holding_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpHoldingRecordEntity _$RpHoldingRecordEntityFromJson(
    Map<String, dynamic> json) {
  return RpHoldingRecordEntity(
    json['address'] as String,
    json['burning'] as int,
    json['circulation'] as int,
    json['created_at'] as String,
    json['from'] as int,
    json['highest_level'] as int,
    json['holding'] as int,
    json['id'] as int,
    json['state'] as int,
    json['to'] as int,
    json['total_holding'] as int,
    json['tx_hash'] as String,
    json['type'] as int,
    json['updated_at'] as String,
    json['withdraw'] as int,
  );
}

Map<String, dynamic> _$RpHoldingRecordEntityToJson(
        RpHoldingRecordEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'burning': instance.burning,
      'circulation': instance.circulation,
      'created_at': instance.createdAt,
      'from': instance.from,
      'highest_level': instance.highestLevel,
      'holding': instance.holding,
      'id': instance.id,
      'state': instance.state,
      'to': instance.to,
      'total_holding': instance.totalHolding,
      'tx_hash': instance.txHash,
      'type': instance.type,
      'updated_at': instance.updatedAt,
      'withdraw': instance.withdraw,
    };
