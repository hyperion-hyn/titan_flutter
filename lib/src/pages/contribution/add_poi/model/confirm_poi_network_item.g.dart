// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_poi_network_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmPoiNetworkItem _$ConfirmPoiNetworkItemFromJson(
    Map<String, dynamic> json) {
  return ConfirmPoiNetworkItem(
    json['id'] as String,
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['Properties'] == null
        ? null
        : Properties.fromJson(json['Properties'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ConfirmPoiNetworkItemToJson(
        ConfirmPoiNetworkItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location': instance.location,
      'Properties': instance.properties,
    };

Properties _$PropertiesFromJson(Map<String, dynamic> json) {
  return Properties(
    json['name'] as String,
    json['address'] as String,
    json['category'] as String,
    json['ext'] as String,
    json['state'] as int,
    json['phone'] as String,
    json['work_time'] as String,
  );
}

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'category': instance.category,
      'ext': instance.ext,
      'state': instance.state,
      'phone': instance.phone,
      'work_time': instance.workTime,
    };
