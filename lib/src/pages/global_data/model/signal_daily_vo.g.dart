// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_daily_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalDailyVo _$SignalDailyVoFromJson(Map<String, dynamic> json) {
  return SignalDailyVo(
    (json['gps'] as List)
        ?.map((e) =>
            e == null ? null : Signal.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['wifi'] as List)
        ?.map((e) =>
            e == null ? null : Signal.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['blue_tooth'] as List)
        ?.map((e) =>
            e == null ? null : Signal.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['cellular'] as List)
        ?.map((e) =>
            e == null ? null : Signal.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SignalDailyVoToJson(SignalDailyVo instance) =>
    <String, dynamic>{
      'gps': instance.gps,
      'wifi': instance.wifi,
      'blue_tooth': instance.blueTooth,
      'cellular': instance.cellular,
    };

Signal _$SignalFromJson(Map<String, dynamic> json) {
  return Signal(
    json['day'] as String,
    json['count'] as int,
  );
}

Map<String, dynamic> _$SignalToJson(Signal instance) => <String, dynamic>{
      'day': instance.day,
      'count': instance.count,
    };
