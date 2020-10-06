// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_reward_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRewardEntity _$UserRewardEntityFromJson(Map<String, dynamic> json) {
  return UserRewardEntity(
    json['node_num'] as int,
    json['reward'] as int,
  );
}

Map<String, dynamic> _$UserRewardEntityToJson(UserRewardEntity instance) =>
    <String, dynamic>{
      'node_num': instance.nodeNum,
      'reward': instance.reward,
    };
