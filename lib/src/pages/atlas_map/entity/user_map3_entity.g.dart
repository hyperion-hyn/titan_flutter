// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_map3_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMap3Entity _$UserMap3EntityFromJson(Map<String, dynamic> json) {
  return UserMap3Entity(
    json['address'] as String,
    json['created_at'] as String,
    json['creator'] as int,
    json['id'] as int,
    json['node_id'] as String,
    json['reward'] as String,
    json['reward_history'] as String,
    json['staking'] as String,
    json['status'] as int,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$UserMap3EntityToJson(UserMap3Entity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'created_at': instance.createdAt,
      'creator': instance.creator,
      'id': instance.id,
      'node_id': instance.nodeId,
      'reward': instance.reward,
      'reward_history': instance.rewardHistory,
      'staking': instance.staking,
      'status': instance.status,
      'updated_at': instance.updatedAt,
    };
