// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_contribution_poi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserContributionPoi _$UserContributionPoiFromJson(Map<String, dynamic> json) {
  return UserContributionPoi(
    json['id'] as String,
    json['name'] as String,
    json['address'] as String,
    json['category'] as String,
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['ext'] as String,
    json['state'] as int,
    json['phone'] as String,
    json['work_time'] as String,
    (json['images'] as List)?.map((e) => e as String)?.toList(),
    json['postcode'] as String,
    json['website'] as String,
    json['myself'] as bool,
  )..remark = json['remark'] as String;
}

Map<String, dynamic> _$UserContributionPoiToJson(
        UserContributionPoi instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'category': instance.category,
      'location': instance.location,
      'ext': instance.ext,
      'state': instance.state,
      'phone': instance.phone,
      'work_time': instance.workTime,
      'images': instance.images,
      'postcode': instance.postcode,
      'website': instance.website,
      'remark': instance.remark,
      'remark': instance.myself,
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

UserContributionPois _$UserContributionPoisFromJson(Map<String, dynamic> json) {
  return UserContributionPois(
    (json['coordinates'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    (json['pois'] as List)
        ?.map((e) => e == null
            ? null
            : UserContributionPoi.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$UserContributionPoisToJson(
        UserContributionPois instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates,
      'pois': instance.pois,
    };
