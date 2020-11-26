// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_release_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpReleaseInfo _$RpReleaseInfoFromJson(Map<String, dynamic> json) {
  return RpReleaseInfo(
    json['staking_id'] as int,
    json['staking_at'] as int,
    json['hyn_amount'] as String,
    json['rp_amount'] as String,
    json['updated_at'] as int,
    json['amount'] as int,
    json['tx_hash'] as String,
  );
}

Map<String, dynamic> _$RpReleaseInfoToJson(RpReleaseInfo instance) =>
    <String, dynamic>{
      'staking_id': instance.stakingId,
      'staking_at': instance.stakingAt,
      'hyn_amount': instance.hynAmount,
      'rp_amount': instance.rpAmount,
      'updated_at': instance.updatedAt,
      'amount': instance.amount,
      'tx_hash': instance.txHash,
    };
