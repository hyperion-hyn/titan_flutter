// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_release_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPReleaseInfo _$RPReleaseInfoFromJson(Map<String, dynamic> json) {
  return RPReleaseInfo(
    json['amount'] as int,
    json['hyn_amount'] as int,
    json['rp_amount'] as int,
    json['staking_at'] as String,
    json['staking_id'] as int,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$RPReleaseInfoToJson(RPReleaseInfo instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'hyn_amount': instance.hynAmount,
      'rp_amount': instance.rpAmount,
      'staking_at': instance.stakingAt,
      'staking_id': instance.stakingId,
      'updated_at': instance.updatedAt,
    };
