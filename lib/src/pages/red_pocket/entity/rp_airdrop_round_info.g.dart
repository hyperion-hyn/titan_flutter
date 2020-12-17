// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_airdrop_round_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpAirdropRoundInfo _$RpAirdropRoundInfoFromJson(Map<String, dynamic> json) {
  return RpAirdropRoundInfo(
    json['start_time'] as int,
    json['end_time'] as int,
    json['my_rp_count'] as int,
    json['my_rp_amount'] as String,
    json['total_rp_amount'] as String,
    json['current_time'] as int,
  );
}

Map<String, dynamic> _$RpAirdropRoundInfoToJson(RpAirdropRoundInfo instance) => <String, dynamic>{
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'my_rp_count': instance.myRpCount,
      'my_rp_amount': instance.myRpAmount,
      'total_rp_amount': instance.totalRpAmount,
      'current_time': instance.currentTime,
    };
