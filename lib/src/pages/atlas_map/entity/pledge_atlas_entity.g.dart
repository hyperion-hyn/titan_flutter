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
    _$enumDecodeNullable(_$AtlasActionTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$PledgeAtlasEntityToJson(PledgeAtlasEntity instance) =>
    <String, dynamic>{
      'value': instance.value,
      'from': instance.from,
      'gas_limit': instance.gasLimit,
      'nonce': instance.nonce,
      'payload': instance.payload?.toJson(),
      'gas_price': instance.gasPrice,
      'raw_tx': instance.rawTx,
      'to': instance.to,
      'type': _$AtlasActionTypeEnumMap[instance.type],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$AtlasActionTypeEnumMap = {
  AtlasActionType.TRANSFER: 'TRANSFER',
  AtlasActionType.CREATE_MAP3_NODE: 'CREATE_MAP3_NODE',
  AtlasActionType.SPLIT_MAP3_NODE: 'SPLIT_MAP3_NODE',
  AtlasActionType.CANCEL_MAP3_NODE: 'CANCEL_MAP3_NODE',
  AtlasActionType.JOIN_DELEGATE_MAP3: 'JOIN_DELEGATE_MAP3',
  AtlasActionType.CANCEL_DELEGATE_MAP3: 'CANCEL_DELEGATE_MAP3',
  AtlasActionType.CREATE_ATLAS_NODE: 'CREATE_ATLAS_NODE',
  AtlasActionType.JOIN_DELEGATE_ALAS: 'JOIN_DELEGATE_ALAS',
  AtlasActionType.CANCEL_DELEGATE_ALAS: 'CANCEL_DELEGATE_ALAS',
  AtlasActionType.EDIT_ATLAS_NODE: 'EDIT_ATLAS_NODE',
  AtlasActionType.ACTIVE_ATLAS_NODE: 'ACTIVE_ATLAS_NODE',
  AtlasActionType.RECEIVE_ATLAS_REWARD: 'RECEIVE_ATLAS_REWARD',
  AtlasActionType.RECEIVE_MAP3_REWARD: 'RECEIVE_MAP3_REWARD',
  AtlasActionType.EDIT_MAP3_NODE: 'EDIT_MAP3_NODE',
  AtlasActionType.COLLECT_MAP3_NODE: 'COLLECT_MAP3_NODE',
};

PledgeAtlasPayload _$PledgeAtlasPayloadFromJson(Map<String, dynamic> json) {
  return PledgeAtlasPayload(
    json['atlas_address'] as String,
    json['map3_address'] as String,
  );
}

Map<String, dynamic> _$PledgeAtlasPayloadToJson(PledgeAtlasPayload instance) =>
    <String, dynamic>{
      'atlas_address': instance.atlasAddress,
      'map3_address': instance.map3Address,
    };
