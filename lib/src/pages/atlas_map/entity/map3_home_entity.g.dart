// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_home_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3HomeEntity _$Map3HomeEntityFromJson(Map<String, dynamic> json) {
  return Map3HomeEntity(
    json['my_nodes'] == null
        ? []
        : (json['my_nodes'] as List).map((item) => Map3InfoEntity.fromJson(item as Map<String, dynamic>)).toList(),
    json['new_start_nodes'] == null
        ? []
        : (json['new_start_nodes'] as List)
            .map((item) => Map3InfoEntity.fromJson(item as Map<String, dynamic>))
            .toList(),
  );
}

Map<String, dynamic> _$Map3HomeEntityToJson(Map3HomeEntity instance) => <String, dynamic>{
      'my_nodes': instance.myNodes,
      'new_start_nodes': instance.newStartNodes,
    };
