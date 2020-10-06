// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_staking_log_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3StakingLogEntity _$Map3StakingLogEntityFromJson(Map<String, dynamic> json) {
  return Map3StakingLogEntity(
    json['created_at'] as String,
    json['id'] as int,
    json['map3_address'] as String,
    json['staking'] as int,
    json['updated_at'] as String,
    json['user_address'] as String,
  );
}

Map<String, dynamic> _$Map3StakingLogEntityToJson(
        Map3StakingLogEntity instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt,
      'id': instance.id,
      'map3_address': instance.map3Address,
      'staking': instance.staking,
      'updated_at': instance.updatedAt,
      'user_address': instance.userAddress,
    };
