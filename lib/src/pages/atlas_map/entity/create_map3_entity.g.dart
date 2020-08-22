// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_map3_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMap3Entity _$CreateMap3EntityFromJson(Map<String, dynamic> json) {
  return CreateMap3Entity(
    json['amount'] as int,
    json['from'] as String,
    json['gas_limit'] as int,
    json['nonce'] as int,
    json['payload'] == null
        ? null
        : CreateMap3Payload.fromJson(json['payload'] as Map<String, dynamic>),
    json['price'] as String,
    json['raw_tx'] as String,
    json['to'] as String,
    AtlasActionType.values[json['type'] as int],
  );
}

Map<String, dynamic> _$CreateMap3EntityToJson(CreateMap3Entity instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'from': instance.from,
      'gas_limit': instance.gasLimit,
      'nonce': instance.nonce,
      'payload': instance.payload,
      'price': instance.price,
      'raw_tx': instance.rawTx,
      'to': instance.to,
      'type': instance.type,
    };

CreateMap3Payload _$CreateMap3PayloadFromJson(Map<String, dynamic> json) {
  return CreateMap3Payload(
    json['connect'] as String,
    json['describe'] as String,
    json['fee_rate'] as String,
    json['home'] as String,
    json['name'] as String,
    json['node_id'] as String,
    json['parent_node_id'] as String,
    json['pic'] as String,
    json['pledge'] as int,
    json['provider'] as String,
    json['region'] as String,
    json['staking'] as String,
  );
}

Map<String, dynamic> _$CreateMap3PayloadToJson(CreateMap3Payload instance) =>
    <String, dynamic>{
      'connect': instance.connect,
      'describe': instance.describe,
      'fee_rate': instance.feeRate,
      'home': instance.home,
      'name': instance.name,
      'node_id': instance.nodeId,
      'parent_node_id': instance.parentNodeId,
      'pic': instance.pic,
      'pledge': instance.pledge,
      'provider': instance.provider,
      'region': instance.region,
      'staking': instance.staking,
    };
