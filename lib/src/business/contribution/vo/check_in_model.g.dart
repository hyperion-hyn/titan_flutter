// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInModel _$CheckInModelFromJson(Map<String, dynamic> json) {
  return CheckInModel(
    addPoiTimes: json['addPoiTimes'] as int,
    scanTimes: json['scanTimes'] as int,
    verifyPoiTimes: json['verifyPoiTimes'] as int,
  );
}

Map<String, dynamic> _$CheckInModelToJson(CheckInModel instance) =>
    <String, dynamic>{
      'scanTimes': instance.scanTimes,
      'addPoiTimes': instance.addPoiTimes,
      'verifyPoiTimes': instance.verifyPoiTimes,
    };
