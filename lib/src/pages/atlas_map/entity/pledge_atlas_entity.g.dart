// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pledge_atlas_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PledgeAtlasEntity _$PledgeAtlasEntityFromJson(Map<String, dynamic> json) {
  return PledgeAtlasEntity(
    json['value'] as String,
    json['from'] as String,
    json['gas_limit'] as int,
    json['nonce'] as int,
    json['payload'] == null
        ? null
        : PledgeAtlasPayload.fromJson(json['payload'] as Map<String, dynamic>),
    json['gas_price'] as String,
    json['raw_tx'] as String,
    json['to'] as String,
    AtlasActionType.values[json['type'] as int],
  );
}

Map<String, dynamic> _$PledgeAtlasEntityToJson(PledgeAtlasEntity instance) =>
    <String, dynamic>{
      'value': instance.value,
      'from': instance.from,
      'gas_limit': instance.gasLimit,
      'nonce': instance.nonce,
      'payload': instance.payload,
      'gas_price': instance.gasPrice,
      'raw_tx': instance.rawTx,
      'to': instance.to,
      'type': instance.type,
    };

PledgeAtlasPayload _$AtlasPayloadFromJson(Map<String, dynamic> json) {
  return PledgeAtlasPayload(
    json['atlas_address'] as String,
    json['map3_address'] as String,
  );
}

Map<String, dynamic> _$AtlasPayloadToJson(PledgeAtlasPayload instance) =>
    <String, dynamic>{
      'atlas_address': instance.atlasAddress,
      'map3_address': instance.map3Address,
    };
