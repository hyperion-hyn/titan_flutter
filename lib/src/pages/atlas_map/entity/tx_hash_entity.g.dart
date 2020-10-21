// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx_hash_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxHashEntity _$TxHashEntityFromJson(Map<String, dynamic> json) {
  return TxHashEntity(
    json['tx_hash'] as String,
    json['node_id'] as String,
  );
}

Map<String, dynamic> _$TxHashEntityToJson(TxHashEntity instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'node_id': instance.nodeId,
    };
