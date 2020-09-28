// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_default_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeDefaultEntity _$NodeDefaultEntityFromJson(Map<String, dynamic> json) {
  return NodeDefaultEntity(
    json['address'] as String,
    json['txHash'] as String,
    json['gasprice'] as int,
    name: json['name'] as String,
    amount: json['amount'] as double,
    publicKey: json['publicKey'] as String,
    nodeProvider: json['nodeProvider'] as String,
    nodeRegion: json['nodeRegion'] as String,
    shareKey: json['shareKey'] as String,
  );
}

Map<String, dynamic> _$NodeDefaultEntityToJson(NodeDefaultEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'gasprice': instance.gasPrice,
      'amount': instance.amount,
      'publicKey': instance.publicKey,
      'txHash': instance.txHash,
      'nodeProvider': instance.nodeProvider,
      'nodeRegion': instance.nodeRegion,
      'shareKey': instance.shareKey,
    };
