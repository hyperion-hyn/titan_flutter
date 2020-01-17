// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInModel _$CheckInModelFromJson(Map<String, dynamic> json) {
  return CheckInModel(
    detail: json['detail'] == null
        ? null
        : CheckInDetail.fromJson(json['detail'] as Map<String, dynamic>),
    finishTaskNum: json['total'] as int,
  );
}

Map<String, dynamic> _$CheckInModelToJson(CheckInModel instance) =>
    <String, dynamic>{
      'total': instance.finishTaskNum,
      'detail': instance.detail,
    };

CheckInDetail _$CheckInDetailFromJson(Map<String, dynamic> json) {
  return CheckInDetail(
    scanTimes: json['scanSignal'] as int,
    addPoiTimes: json['postPOI'] as int,
    verifyPoiTimes: json['confirmPOI'] as int,
  );
}

Map<String, dynamic> _$CheckInDetailToJson(CheckInDetail instance) =>
    <String, dynamic>{
      'scanSignal': instance.scanTimes,
      'postPOI': instance.addPoiTimes,
      'confirmPOI': instance.verifyPoiTimes,
    };
