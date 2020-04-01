// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_total_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalTotalVo _$SignalTotalVoFromJson(Map<String, dynamic> json) {
  return SignalTotalVo(
    json['gps_total'] as int,
    json['wifi_total'] as int,
    json['blue_tooth_total'] as int,
    json['cellular_total'] as int,
  );
}

Map<String, dynamic> _$SignalTotalVoToJson(SignalTotalVo instance) =>
    <String, dynamic>{
      'gps_total': instance.gpsTotal,
      'wifi_total': instance.wifiTotal,
      'blue_tooth_total': instance.blueToothTotal,
      'cellular_total': instance.cellularTotal,
    };
