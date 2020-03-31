// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_node_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3NodeVo _$Map3NodeVoFromJson(Map<String, dynamic> json) {
  return Map3NodeVo(
    json['dmapperDownloads'] as List,
    json['dmapperUsers'] as List,
    json['hynTokenUsers'] as List,
    json['tileRequests'] as List,
    json['tileTotalRequests'] as int,
    (json['tiles'] as List)
        ?.map(
            (e) => e == null ? null : Tiles.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['totalDmapperDownloads'] as int,
    json['totalDmapperUsers'] as int,
    json['totalHynTokenUsers'] as int,
    json['totalTiles'] as int,
  );
}

Map<String, dynamic> _$Map3NodeVoToJson(Map3NodeVo instance) =>
    <String, dynamic>{
      'dmapperDownloads': instance.dmapperDownloads,
      'dmapperUsers': instance.dmapperUsers,
      'hynTokenUsers': instance.hynTokenUsers,
      'tileRequests': instance.tileRequests,
      'tileTotalRequests': instance.tileTotalRequests,
      'tiles': instance.tiles,
      'totalDmapperDownloads': instance.totalDmapperDownloads,
      'totalDmapperUsers': instance.totalDmapperUsers,
      'totalHynTokenUsers': instance.totalHynTokenUsers,
      'totalTiles': instance.totalTiles,
    };

Tiles _$TilesFromJson(Map<String, dynamic> json) {
  return Tiles(
    json['id'] == null ? null : Id.fromJson(json['id'] as Map<String, dynamic>),
    json['count'] as int,
  );
}

Map<String, dynamic> _$TilesToJson(Tiles instance) => <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
    };

Id _$IdFromJson(Map<String, dynamic> json) {
  return Id(
    json['city'] as String,
    (json['location'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
  );
}

Map<String, dynamic> _$IdToJson(Id instance) => <String, dynamic>{
      'city': instance.city,
      'location': instance.location,
    };
