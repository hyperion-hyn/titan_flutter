// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atlas_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtlasInfoEntity _$AtlasInfoEntityFromJson(Map<String, dynamic> json) {
  return AtlasInfoEntity(
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
    NodeJoinType.values[json['join'] as int],
    json['max_staking'] as String,
    (json['my_map3'] as List)
        ?.map((e) => e == null
            ? null
            : Map3NodeEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['name'] as String,
    json['node_id'] as String,
    json['pic'] as String,
    json['reward'] as String,
    json['reward_rate'] as String,
    json['sign_rate'] as String,
    json['staking'] as String,
    NodeStatus.values[json['status'] as int],
    AtlasNodeType.values[json['type'] as int],
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$AtlasInfoEntityToJson(AtlasInfoEntity instance) =>
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
      'join': instance.join.index,
      'max_staking': instance.maxStaking,
      'my_map3': List.generate(instance.myMap3.length, (index) => instance.myMap3[index].toJson()).toList(),
      'name': instance.name,
      'node_id': instance.nodeId,
      'pic': instance.pic,
      'reward': instance.reward,
      'reward_rate': instance.rewardRate,
      'sign_rate': instance.signRate,
      'staking': instance.staking,
      'status': instance.status.index,
      'type': instance.type.index,
      'updated_at': instance.updatedAt,
    };
