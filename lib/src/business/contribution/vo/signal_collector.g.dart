// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalCollector _$SignalCollectorFromJson(Map<String, dynamic> json) {
  return SignalCollector(
    json['location'] == null
        ? null
        : LatLng.fromJson(json['location'] as Map<String, dynamic>),
    json['data'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$SignalCollectorToJson(SignalCollector instance) =>
    <String, dynamic>{
      'location': instance.location,
      'data': instance.data,
    };
