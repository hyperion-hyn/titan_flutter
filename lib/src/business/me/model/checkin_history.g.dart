// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckinHistory _$CheckinHistoryFromJson(Map<String, dynamic> json) {
  return CheckinHistory(
    json['day'] as String,
    json['total'] as int,
    (json['detail'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$CheckinHistoryToJson(CheckinHistory instance) =>
    <String, dynamic>{
      'day': instance.day,
      'total': instance.total,
      'detail': instance.detail,
    };
