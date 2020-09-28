// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetHistory _$AssetHistoryFromJson(Map<String, dynamic> json) {
  return AssetHistory(
    json['name'] as String,
    json['id'] as String,
    json['type'] as String,
    json['balance'] as String,
    json['fee'] as String,
    json['tx_id'] as String,
    json['status'] as String,
    json['mtime'] as String,
    json['ctime'] as String,
  );
}

Map<String, dynamic> _$AssetHistoryToJson(AssetHistory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'type': instance.type,
      'balance': instance.balance,
      'fee': instance.fee,
      'tx_id': instance.txId,
      'status': instance.status,
      'mtime': instance.mtime,
      'ctime': instance.ctime,
    };
