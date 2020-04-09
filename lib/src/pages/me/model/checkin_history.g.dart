// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckinHistory _$CheckinHistoryFromJson(Map<String, dynamic> json) {
  return CheckinHistory(
    json['day'] as String,
    json['total'] as int,
    json['detail'] == null
        ? null
        : CheckInDetail.fromJson(json['detail'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CheckinHistoryToJson(CheckinHistory instance) =>
    <String, dynamic>{
      'day': instance.day,
      'total': instance.total,
      'detail': instance.detail,
    };
