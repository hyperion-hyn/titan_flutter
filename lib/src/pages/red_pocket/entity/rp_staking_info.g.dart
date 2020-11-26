// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_staking_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpStakingInfo _$RpStakingInfoFromJson(Map<String, dynamic> json) {
  return RpStakingInfo(
    json['id'] as int,
    json['created_at'] as String,
    json['updated_at'] as String,
    json['staking_at'] as String,
    json['tx_hash'] as String,
    json['staking_id'] as int,
    json['address'] as String,
    json['hyn_amount'] as String,
    json['release_rp'] as String,
    json['release_times'] as int,
    json['release_limit'] as int,
    json['expect_retrieve_time'] as String,
    json['status'] as int,
  );
}

Map<String, dynamic> _$RpStakingInfoToJson(RpStakingInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'staking_at': instance.stakingAt,
      'tx_hash': instance.txHash,
      'staking_id': instance.stakingId,
      'address': instance.address,
      'hyn_amount': instance.hynAmount,
      'release_rp': instance.releaseRp,
      'release_times': instance.releaseTimes,
      'release_limit': instance.releaseLimit,
      'expect_retrieve_time': instance.expectRetrieveTime,
      'status': instance.status,
    };
