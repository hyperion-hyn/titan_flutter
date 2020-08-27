// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3InfoEntity _$Map3InfoEntityFromJson(Map<String, dynamic> json) {
  return Map3InfoEntity(
    json['address'] as String,
    (json['atlas'] as List)
        ?.map((e) => e == null ? null : AtlasNodeEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['contact'] as String,
    json['created_at'] as String,
    json['creator'] as String,
    json['describe'] as String,
    json['end_time'] as String,
    json['fee_rate'] as String,
    json['home'] as String,
    json['id'] as int,
    NodeJoinType.values[(json['join'] as int) ?? 0],
    json['name'] as String,
    json['node_id'] as String,
    json['parent_node_id'] as String,
    json['pic'] as String,
    json['provider'] as String,
    json['region'] as String,
    json['reward'] as String,
    json['reward_mine'] as String,
    json['reward_rate'] as String,
    json['staking'] as String,
    json['staking_mine'] as String,
    json['start_time'] as String,
    Map3NodeStatus.values[(json['status'] as int) ?? 0],
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$Map3InfoEntityToJson(Map3InfoEntity instance) => <String, dynamic>{
      'address': instance.address,
      'atlas': instance.atlas,
      'contact': instance.contact,
      'created_at': instance.createdAt,
      'creator': instance.creator,
      'describe': instance.describe,
      'end_time': instance.endTime,
      'fee_rate': instance.feeRate,
      'home': instance.home,
      'id': instance.id,
      'join': instance.join,
      'name': instance.name,
      'node_id': instance.nodeId,
      'parent_node_id': instance.parentNodeId,
      'pic': instance.pic,
      'provider': instance.provider,
      'region': instance.region,
      'reward': instance.reward,
      'reward_mine': instance.rewardMine,
      'reward_rate': instance.rewardRate,
      'staking': instance.staking,
      'staking_mine': instance.stakingMine,
      'start_time': instance.startTime,
      'status': instance.status,
      'updated_at': instance.updatedAt,
    };
