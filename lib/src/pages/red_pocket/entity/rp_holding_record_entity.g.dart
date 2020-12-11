// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_holding_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPLevelHistory _$RpHoldingRecordEntityFromJson(
    Map<String, dynamic> json) {
  return RPLevelHistory(
    json['address'] as String,
    json['burning'] as String,
    json['circulation'] as String,
    json['created_at'] as String,
    json['from'] as int,
    json['highest_level'] as int,
    json['holding'] as String,
    json['id'] as int,
    json['state'] as int,
    json['to'] as int,
    json['total_holding'] as String,
    json['tx_hash'] as String,
    json['type'] as int,
    json['updated_at'] as String,
    json['withdraw'] as String,
  );
}

Map<String, dynamic> _$RpHoldingRecordEntityToJson(
        RPLevelHistory instance) =>
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
