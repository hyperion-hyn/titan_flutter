// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_airdrop_round_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpAirdropRoundInfo _$RpAirdropRoundInfoFromJson(Map<String, dynamic> json) {
  return RpAirdropRoundInfo(
    json['startTime'] as int,
    json['endTime'] as int,
    json['myRpCount'] as int,
    json['myRpAmount'] as String,
    json['totalRpAmount'] as String,
  );
}

Map<String, dynamic> _$RpAirdropRoundInfoToJson(RpAirdropRoundInfo instance) =>
    <String, dynamic>{
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'myRpCount': instance.myRpCount,
      'myRpAmount': instance.myRpAmount,
      'totalRpAmount': instance.totalRpAmount,
    };
