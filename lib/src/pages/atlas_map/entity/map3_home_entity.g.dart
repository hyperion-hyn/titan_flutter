// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_home_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3HomeEntity _$Map3HomeEntityFromJson(Map<String, dynamic> json) {
  return Map3HomeEntity(
    (json['my_nodes'] as List)
        ?.map((e) => e == null
            ? null
            : Map3InfoEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['new_start_nodes'] as List)
        ?.map((e) => e == null
            ? null
            : Map3InfoEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['points'] as String,
  );
}

Map<String, dynamic> _$Map3HomeEntityToJson(Map3HomeEntity instance) =>
    <String, dynamic>{
      'my_nodes': instance.myNodes,
      'new_start_nodes': instance.newStartNodes,
      'points': instance.points,
    };
