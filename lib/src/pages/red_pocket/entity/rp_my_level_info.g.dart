// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_my_level_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpMyLevelInfo _$RpMyLevelInfoFromJson(Map<String, dynamic> json) {
  return RpMyLevelInfo(
    json['current_holding'] as String,
    json['curr_burning'] as String,
    json['current_level'] as int,
    json['highest_level'] as int,
  );
}

Map<String, dynamic> _$RpMyLevelInfoToJson(RpMyLevelInfo instance) =>
    <String, dynamic>{
      'current_holding': instance.currentHolding,
      'curr_burning': instance.currBurning,
      'current_level': instance.currentLevel,
      'highest_level': instance.highestLevel,
    };
