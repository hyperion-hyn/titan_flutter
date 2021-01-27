// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atlas_node_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtlasNodeEntity _$AtlasNodeEntityFromJson(Map<String, dynamic> json) {
  return AtlasNodeEntity(
    json['address'] as String,
    json['block_num'] as int,
    json['bls_key'] as String,
    json['bls_sign'] as String,
    json['contact'] as String,
    json['created_at'] as String,
    json['creator'] as String,
    json['describe'] as String,
    json['fee_rate'] as String,
    json['fee_rate_max'] as String,
    json['fee_rate_trim'] as String,
    json['home'] as String,
    json['id'] as int,
    json['max_staking'] as int,
    json['name'] as String,
    json['node_id'] as String,
    json['pic'] as String,
    json['reward'] as int,
    json['reward_rate'] as int,
    json['sign_rate'] as int,
    json['staking'] as int,
    _$enumDecodeNullable(_$AtlasInfoStatusEnumMap, json['status']),
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$AtlasNodeEntityToJson(AtlasNodeEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'block_num': instance.blockNum,
      'bls_key': instance.blsKey,
      'bls_sign': instance.blsSign,
      'contact': instance.contact,
      'created_at': instance.createdAt,
      'creator': instance.creator,
      'describe': instance.describe,
      'fee_rate': instance.feeRate,
      'fee_rate_max': instance.feeRateMax,
      'fee_rate_trim': instance.feeRateTrim,
      'home': instance.home,
      'id': instance.id,
      'max_staking': instance.maxStaking,
      'name': instance.name,
      'node_id': instance.nodeId,
      'pic': instance.pic,
      'reward': instance.reward,
      'reward_rate': instance.rewardRate,
      'sign_rate': instance.signRate,
      'staking': instance.staking,
      'status': _$AtlasInfoStatusEnumMap[instance.status],
      'updated_at': instance.updatedAt,
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

const _$AtlasInfoStatusEnumMap = {
  AtlasInfoStatus.CREATE_ING: 'CREATE_ING',
  AtlasInfoStatus.CREATE_FAIL: 'CREATE_FAIL',
  AtlasInfoStatus.CREATE_SUCCESS_UN_CANCEL: 'CREATE_SUCCESS_UN_CANCEL',
  AtlasInfoStatus.CREATE_SUCCESS_CANCEL_NODE_ING:
      'CREATE_SUCCESS_CANCEL_NODE_ING',
  AtlasInfoStatus.CANCEL_NODE_SUCCESS_IS_IDLE: 'CANCEL_NODE_SUCCESS_IS_IDLE',
};
