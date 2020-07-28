// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetHistory _$AssetHistoryFromJson(Map<String, dynamic> json) {
  return AssetHistory(
    json['address'] as String,
    (json['balance'] as num)?.toDouble(),
    json['ctime'] as int,
    (json['fee'] as num)?.toDouble(),
    json['id'] as int,
    json['name'] as String,
    json['status'] as int,
    json['txid'] as String,
    json['type'] as String,
  );
}

Map<String, dynamic> _$AssetHistoryToJson(AssetHistory instance) =>
    <String, dynamic>{
      'address': instance.address,
      'balance': instance.balance,
      'ctime': instance.ctime,
      'fee': instance.fee,
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'txid': instance.txid,
      'type': instance.type,
    };
