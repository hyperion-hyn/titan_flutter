// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_weekly_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalWeeklyVo _$SignalWeeklyVoFromJson(Map<String, dynamic> json) {
  return SignalWeeklyVo(
    json['blue_tooth_count'] as int,
    json['cellular_count'] as int,
    json['gps_count'] as int,
    json['wifi_count'] as int,
  );
}

Map<String, dynamic> _$SignalWeeklyVoToJson(SignalWeeklyVo instance) =>
    <String, dynamic>{
      'blue_tooth_count': instance.blueToothCount,
      'cellular_count': instance.cellularCount,
      'gps_count': instance.gpsCount,
      'wifi_count': instance.wifiCount,
    };
