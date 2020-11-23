// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3UserEntity _$Map3UserEntityFromJson(Map<String, dynamic> json) {
  return Map3UserEntity(
    json['address'] as String,
    json['creator'] as int,
    json['map3_address'] as String,
    json['name'] as String,
    json['pic'] as String,
    json['staking'] as String,
  );
}

Map<String, dynamic> _$Map3UserEntityToJson(Map3UserEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'creator': instance.creator,
      'map3_address': instance.map3Address,
      'name': instance.name,
      'pic': instance.pic,
      'staking': instance.staking,
    };
