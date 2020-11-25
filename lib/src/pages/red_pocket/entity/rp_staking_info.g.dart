// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_staking_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPStakingInfo _$RPStakingInfoFromJson(Map<String, dynamic> json) {
  return RPStakingInfo(
    json['address'] as String,
    json['created_at'] as String,
    json['hyn_amount'] as int,
    json['id'] as int,
    json['staking_id'] as int,
    json['status'] as int,
    json['tx_hash'] as String,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$RPStakingInfoToJson(RPStakingInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'created_at': instance.createdAt,
      'hyn_amount': instance.hynAmount,
      'id': instance.id,
      'staking_id': instance.stakingId,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'updated_at': instance.updatedAt,
    };
