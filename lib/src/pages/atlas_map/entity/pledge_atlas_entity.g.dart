// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pledge_atlas_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PledgeAtlasEntity _$PledgeAtlasEntityFromJson(Map<String, dynamic> json) {
  return PledgeAtlasEntity(
    json['amount'] as int,
    json['from'] as String,
    json['gas_limit'] as int,
    json['nonce'] as int,
    json['payload'] == null
        ? null
        : AtlasPayload.fromJson(json['payload'] as Map<String, dynamic>),
    json['price'] as int,
    json['raw_tx'] as String,
    json['to'] as String,
    AtlasActionType.values[json['type'] as int],
  );
}

Map<String, dynamic> _$PledgeAtlasEntityToJson(PledgeAtlasEntity instance) =>
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

AtlasPayload _$AtlasPayloadFromJson(Map<String, dynamic> json) {
  return AtlasPayload(
    json['atlas_node_id'] as String,
    json['map3_node_id'] as String,
  );
}

Map<String, dynamic> _$AtlasPayloadToJson(AtlasPayload instance) =>
    <String, dynamic>{
      'atlas_node_id': instance.atlasNodeId,
      'map3_node_id': instance.map3NodeId,
    };
