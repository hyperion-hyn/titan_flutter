// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rp_share_poi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRpSharePoi _$UserRpSharePoiFromJson(Map<String, dynamic> json) {
  return UserRpSharePoi(
    json['id'] as String,
    LatLngConverter.latLngFromJson(json['latLng']),
  );
}

Map<String, dynamic> _$UserRpSharePoiToJson(UserRpSharePoi instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latLng': LatLngConverter.latLngToJson(instance.latLng),
    };
