// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_node_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3NodeEntity _$Map3NodeEntityFromJson(Map<String, dynamic> json) {
  return Map3NodeEntity(
    json['address'] as String,
    json['contact'] as String,
    json['created_at'] as String,
    json['creator'] as String,
    json['describe'] as String,
    json['end_time'] as String,
    json['fee_rate'] as int,
    json['home'] as String,
    json['id'] as int,
    json['name'] as String,
    json['node_id'] as String,
    json['parent_node_id'] as String,
    json['pic'] as String,
    json['provider'] as String,
    json['region'] as String,
    json['reward'] as String,
    json['reward_rate'] as String,
    json['staking'] as String,
    json['start_time'] as String,
    NodeStatus.values[json['status'] as int],
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$Map3NodeEntityToJson(Map3NodeEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'contact': instance.contact,
      'created_at': instance.createdAt,
      'creator': instance.creator,
      'describe': instance.describe,
      'end_time': instance.endTime,
      'fee_rate': instance.feeRate,
      'home': instance.home,
      'id': instance.id,
      'name': instance.name,
      'node_id': instance.nodeId,
      'parent_node_id': instance.parentNodeId,
      'pic': instance.pic,
      'provider': instance.provider,
      'region': instance.region,
      'reward': instance.reward,
      'reward_rate': instance.rewardRate,
      'staking': instance.staking,
      'start_time': instance.startTime,
      'status': instance.status,
      'updated_at': instance.updatedAt,
    };
