// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_staking_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3StakingEntity _$Map3StakingEntityFromJson(Map<String, dynamic> json) {
  return Map3StakingEntity(
    json['map3_nodes'] == null
        ? []
        : (json['my_nodes'] as List).map((item) => Map3InfoEntity.fromJson(item as Map<String, dynamic>)).toList(),
    json['can_staking_num'] as int,
  );
}

Map<String, dynamic> _$Map3StakingEntityToJson(Map3StakingEntity instance) => <String, dynamic>{
      'map3_nodes': instance.map3Nodes,
      'can_staking_num': instance.canStakingNum,
    };
