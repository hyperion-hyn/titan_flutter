// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_join_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartJoinInstance _$StartJoinInstanceFromJson(Map<String, dynamic> json) {
  return StartJoinInstance(
    json['address'] as String,
    json['provider'] as String,
    json['region'] as String,
  );
}

Map<String, dynamic> _$StartJoinInstanceToJson(StartJoinInstance instance) =>
    <String, dynamic>{
      'address': instance.address,
      'provider': instance.provider,
      'region': instance.region,
    };
