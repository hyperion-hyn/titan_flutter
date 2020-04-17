// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_default_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeDefaultEntity _$NodeDefaultEntityFromJson(Map<String, dynamic> json) {
  return NodeDefaultEntity(
    json['address'] as String,
    json['txHash'] as String,
    name: json['name'] as String,
    amount: json['amount'] as int,
    publicKey: json['publicKey'] as String,
    nodeProvider: json['nodeProvider'] as String,
    nodeRegion: json['nodeRegion'] as String,
  );
}

Map<String, dynamic> _$NodeDefaultEntityToJson(NodeDefaultEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'amount': instance.amount,
      'publicKey': instance.publicKey,
      'txHash': instance.txHash,
      'nodeProvider': instance.nodeProvider,
      'nodeRegion': instance.nodeRegion,
    };
