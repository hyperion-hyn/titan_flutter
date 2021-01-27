// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_atlas_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAtlasEntity _$CreateAtlasEntityFromJson(Map<String, dynamic> json) {
  return CreateAtlasEntity(
    json['amount'] as String,
    json['from'] as String,
    json['gas_limit'] as int,
    json['nonce'] as int,
    json['payload'] == null
        ? null
        : CreateAtlasPayload.fromJson(json['payload'] as Map<String, dynamic>),
    json['price'] as String,
    json['raw_tx'] as String,
    json['to'] as String,
    _$enumDecodeNullable(_$AtlasActionTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$CreateAtlasEntityToJson(CreateAtlasEntity instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'from': instance.from,
      'gas_limit': instance.gasLimit,
      'nonce': instance.nonce,
      'payload': instance.payload,
      'price': instance.price,
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

CreateAtlasPayload _$CreateAtlasPayloadFromJson(Map<String, dynamic> json) {
  return CreateAtlasPayload(
    json['bls_add_key'] as String,
    json['bls_add_sign'] as String,
    json['bls_rm_key'] as String,
    json['contact'] as String,
    json['describe'] as String,
    json['fee_rate'] as String,
    json['fee_rate_max'] as String,
    json['fee_rate_trim'] as String,
    json['home'] as String,
    json['map3_address'] as String,
    json['max_staking'] as String,
    json['name'] as String,
    json['node_id'] as String,
    json['atlas_address'] as String,
    json['pic'] as String,
  );
}

Map<String, dynamic> _$CreateAtlasPayloadToJson(CreateAtlasPayload instance) =>
    <String, dynamic>{
      'bls_add_key': instance.blsAddKey,
      'bls_add_sign': instance.blsAddSign,
      'bls_rm_key': instance.blsRmSign,
      'contact': instance.contact,
      'describe': instance.describe,
      'fee_rate': instance.feeRate,
      'fee_rate_max': instance.feeRateMax,
      'fee_rate_trim': instance.feeRateTrim,
      'home': instance.home,
      'map3_address': instance.map3Address,
      'max_staking': instance.maxStaking,
      'name': instance.name,
      'node_id': instance.nodeId,
      'atlas_address': instance.atlasAddress,
      'pic': instance.pic,
    };
