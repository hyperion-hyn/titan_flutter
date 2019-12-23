// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latlng.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng _$LatLngFromJson(Map<String, dynamic> json) {
  return LatLng(
    (json['lat'] as num)?.toDouble(),
    (json['lon'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
    };
