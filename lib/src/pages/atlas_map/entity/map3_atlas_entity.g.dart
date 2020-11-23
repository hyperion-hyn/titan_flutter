// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_atlas_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3AtlasEntity _$Map3AtlasEntityFromJson(Map<String, dynamic> json) {
  return Map3AtlasEntity(
    json['atlas_node_id'] as String,
    json['created_at'] as String,
    json['creator'] as int,
    json['id'] as int,
    json['map3_node_id'] as String,
    json['reward'] as String,
    json['staking'] as String,
    json['status'] as int,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$Map3AtlasEntityToJson(Map3AtlasEntity instance) =>
    <String, dynamic>{
      'atlas_node_id': instance.atlasNodeId,
      'created_at': instance.createdAt,
      'creator': instance.creator,
      'id': instance.id,
      'map3_node_id': instance.map3NodeId,
      'reward': instance.reward,
      'staking': instance.staking,
      'status': instance.status,
      'updated_at': instance.updatedAt,
    };
