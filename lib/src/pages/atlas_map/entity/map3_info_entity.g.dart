// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3InfoEntity _$Map3InfoEntityFromJson(Map<String, dynamic> json) {
  return Map3InfoEntity(
      json['address'] as String,
      json['bls_key'] as String,
      json['bls_sign'] as String,
      json['atlas'] == null
          ? null
          : AtlasInfoEntity.fromJson(json['atlas'] as Map<String, dynamic>),
      json['contact'] as String,
      json['created_at'] as String,
      json['creator'] as String,
      json['describe'] as String,
      json['end_block'] as int,
      json['fee_rate'] as String,
      json['home'] as String,
      json['id'] as int,
      json['mod'] as int,
      json['mine'] == null
          ? null
          : UserMap3Entity.fromJson(json['mine'] as Map<String, dynamic>),
      json['name'] as String,
      json['node_id'] as String,
      json['parentAddress'] as String,
      json['pic'] as String,
      json['provider'] as String,
      json['region'] as String,
      json['relative'] == null
          ? null
          : Map3AtlasEntity.fromJson(json['relative'] as Map<String, dynamic>),
      json['reward_history'] as String,
      json['reward_rate'] as String,
      json['staking'] as String,
      json['total_pending_taking'] == null ? "0" : json['staking'] as String,
      json['start_block'] as int,
      json['status'] as int,
      json['updated_at'] as String,
      json['start_epoch'] as int,
      json['end_epoch'] as int);
}

Map<String, dynamic> _$Map3InfoEntityToJson(Map3InfoEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'bls_key': instance.blsKey,
      'bls_sign': instance.blsSign,
      'atlas': instance.atlas,
      'contact': instance.contact,
      'created_at': instance.createdAt,
      'creator': instance.creator,
      'describe': instance.describe,
      'end_block': instance.endBlock,
      'fee_rate': instance.feeRate,
      'home': instance.home,
      'id': instance.id,
      'mod': instance.mod,
      'mine': instance.mine,
      'name': instance.name,
      'node_id': instance.nodeId,
      'parent_address': instance.parentAddress,
      'pic': instance.pic,
      'provider': instance.provider,
      'region': instance.region,
      'relative': instance.relative,
      'reward_history': instance.rewardHistory,
      'reward_rate': instance.rewardRate,
      'staking': instance.staking,
      'total_pending_taking': instance.totalPendingStaking,
      'start_block': instance.startBlock,
      'status': instance.status,
      'updated_at': instance.updatedAt,
      'start_epoch': instance.startEpoch,
      'end_epoch': instance.endEpoch,
    };
