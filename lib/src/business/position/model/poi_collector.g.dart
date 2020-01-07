// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoiCollector _$PoiCollectorFromJson(Map<String, dynamic> json) {
  var location = (json['location'] as Map<String, dynamic>);
  var lat = location["lat"] as double;
  var lon = location["lon"] as double;
  return PoiCollector(
    json['category_id'] as String,
    json['location'] == null
        ? null
        : LatLng(lat,lon),
    json['name'] as String,
    json['country_code'] as String,
    json['country'] as String,
    json['state'] as String,
    json['city'] as String,
    json['road'] as String,
    json['address_2'] as String,
    json['house_number'] as String,
    json['postal_code'] as String,
    json['work_time'] as String,
    json['phone'] as String,
    json['website'] as String,
  );
}

Map<String, dynamic> _$PoiCollectorToJson(PoiCollector instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'location': {"lat": instance.location.latitude, "lon": instance.location.longitude},
      'name': instance.name,
      'country_code': instance.countryCode,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'road': instance.road,
      'address_2': instance.address2,
      'house_number': instance.houseNumber,
      'postal_code': instance.postalCode,
      'work_time': instance.workTime,
      'phone': instance.phone,
      'website': instance.website,
    };
