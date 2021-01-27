// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_provider_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeProviderEntity _$NodeProviderEntityFromJson(Map<String, dynamic> json) {
  return NodeProviderEntity(
    json['id'] as String,
    json['name'] as String,
    (json['regions'] as List)
        ?.map((e) =>
            e == null ? null : Regions.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NodeProviderEntityToJson(NodeProviderEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'regions': instance.regions,
    };

Regions _$RegionsFromJson(Map<String, dynamic> json) {
  return Regions(
    json['id'] as String,
    json['name'] as String,
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RegionsToJson(Regions instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
    };

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    (json['coordinates'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    json['type'] as String,
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'coordinates': instance.coordinates,
      'type': instance.type,
    };
