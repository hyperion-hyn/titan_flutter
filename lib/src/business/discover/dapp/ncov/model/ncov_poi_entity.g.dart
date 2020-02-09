// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ncov_poi_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NcovPoiEntity _$NcovPoiEntityFromJson(Map<String, dynamic> json) {
  return NcovPoiEntity(
    json['id'] as String,
    json['name'] as String,
    json['address'] as String,
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    (json['images'] as List)?.map((e) => e as String)?.toList(),
    json['postcode'] as String,
    json['confirmed_count'] as int,
    json['confirmed_type'] as String,
    json['isolation'] as String,
    json['isolation_house_type'] as String,
    (json['symptoms'] as List)?.map((e) => e as String)?.toList(),
    json['symptoms_detail'] as String,
    json['trip'] as String,
    json['security_measures'] as String,
    json['contact_records'] as String,
  );
}

Map<String, dynamic> _$NcovPoiEntityToJson(NcovPoiEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'location': instance.location,
      'images': instance.images,
      'postcode': instance.postcode,
      'confirmed_count': instance.confirmedCount,
      'confirmed_type': instance.confirmedType,
      'isolation': instance.isolation,
      'isolation_house_type': instance.isolationHouseType,
      'symptoms': instance.symptoms,
      'symptoms_detail': instance.symptomsDetail,
      'trip': instance.trip,
      'security_measures': instance.securityMeasures,
      'contact_records': instance.contactRecords,
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
