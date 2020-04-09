// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_level_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLevelInfo _$UserLevelInfoFromJson(Map<String, dynamic> json) {
  return UserLevelInfo(
    json['name'] as String,
    json['level'] as int,
    json['description'] as String,
    (json['reward_rate'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$UserLevelInfoToJson(UserLevelInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'level': instance.level,
      'description': instance.description,
      'reward_rate': instance.rewardRate,
    };
