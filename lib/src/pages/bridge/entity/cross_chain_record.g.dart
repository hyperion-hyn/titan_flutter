// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cross_chain_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrossChainRecord _$CrossChainRecordFromJson(Map<String, dynamic> json) {
  return CrossChainRecord(
    json['symbol'] as String,
    json['sender'] as String,
    json['recipient'] as String,
    json['apply_raw_tx'] as String,
    json['atlas_token_address'] as String,
    json['heco_token_address'] as String,
    json['value'] as String,
    json['atlas_tx'] as String,
    json['heco_tx'] as String,
    json['type'] as int,
    json['status'] as int,
    json['created_at'] as String,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$CrossChainRecordToJson(CrossChainRecord instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'sender': instance.sender,
      'recipient': instance.recipient,
      'apply_raw_tx': instance.applyRawTx,
      'atlas_token_address': instance.atlasTokenAddress,
      'heco_token_address': instance.hecoTokenAddress,
      'value': instance.value,
      'atlas_tx': instance.atlasTx,
      'heco_tx': instance.hecoTx,
      'type': instance.type,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt
    };
