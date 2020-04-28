// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoiCollector _$PoiCollectorFromJson(Map<String, dynamic> json) {
  return PoiCollector(
    json['category_id'] as String,
    LocationConverter.latLngFromJson(json['location']),
    json['name'] as String,
    json['country_code'] as String,
    json['country'] as String,
    json['state'] as String,
    json['city'] as String,
    json['county'] as String,
    json['road'] as String,
    json['address_2'] as String,
    json['house_number'] as String,
    json['postcode'] as String,
    json['work_time'] as String,
    json['phone'] as String,
    json['website'] as String,
  );
}

Map<String, dynamic> _$PoiCollectorToJson(PoiCollector instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'location': LocationConverter.latLngToJson(instance.location),
      'name': instance.name,
      'country_code': instance.countryCode,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'county': instance.county,
      'road': instance.road,
      'address_2': instance.address2,
      'house_number': instance.houseNumber,
      'postcode': instance.postCode,
      'work_time': instance.workTime,
      'phone': instance.phone,
      'website': instance.website,
    };
