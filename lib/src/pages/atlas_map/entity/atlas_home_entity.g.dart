// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atlas_home_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtlasHomeEntity _$AtlasHomeEntityFromJson(Map<String, dynamic> json) {
  return AtlasHomeEntity(
    json['info'] == null
        ? null
        : CommitteeInfoEntity.fromJson(json['info'] as Map<String, dynamic>),
    (json['my_nodes'] as List)
        ?.map((e) => e == null
            ? null
            : AtlasHomeNode.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['points'] as String,
  );
}

Map<String, dynamic> _$AtlasHomeEntityToJson(AtlasHomeEntity instance) =>
    <String, dynamic>{
      'info': instance.info,
      'my_nodes': instance.atlasHomeNodeList,
      'points': instance.points,
    };

CommitteeInfoEntity _$CommitteeInfoEntityFromJson(Map<String, dynamic> json) {
  return CommitteeInfoEntity(
    json['block_height'] as int,
    json['block_num'] as int,
    json['block_num_start'] as int,
    json['candidate'] as int,
    json['elected'] as int,
    json['epoch'] as int,
    json['sec_per_block'] as int,
  );
}

Map<String, dynamic> _$CommitteeInfoEntityToJson(
        CommitteeInfoEntity instance) =>
    <String, dynamic>{
      'block_height': instance.blockHeight,
      'block_num': instance.blockNum,
      'block_num_start': instance.blockNumStart,
      'candidate': instance.candidate,
      'elected': instance.elected,
      'epoch': instance.epoch,
      'sec_per_block': instance.secPerBlock,
    };

AtlasHomeNode _$AtlasHomeNodeFromJson(Map<String, dynamic> json) {
  return AtlasHomeNode(
    json['address'] as String,
    json['block_num'] as int,
    json['bls_key'] as String,
    json['bls_sign'] as String,
    json['contact'] as String,
    json['created_at'] as String,
    json['creator'] as String,
    json['describe'] as String,
    json['fee_rate'] as String,
    json['fee_rate_max'] as String,
    json['fee_rate_trim'] as String,
    json['home'] as String,
    json['id'] as int,
    json['max_staking'] as String,
    json['mod'] as int,
    json['name'] as String,
    json['node_id'] as String,
    json['pic'] as String,
    json['reward'] as String,
    json['reward_history'] as String,
    json['reward_rate'] as String,
    json['sign_rate'] as String,
    json['staking'] as String,
    json['status'] as int,
    json['updated_at'] as String,
  );
}

Map<String, dynamic> _$AtlasHomeNodeToJson(AtlasHomeNode instance) =>
    <String, dynamic>{
      'address': instance.address,
      'block_num': instance.blockNum,
      'bls_key': instance.blsKey,
      'bls_sign': instance.blsSign,
      'contact': instance.contact,
      'created_at': instance.createdAt,
      'creator': instance.creator,
      'describe': instance.describe,
      'fee_rate': instance.feeRate,
      'fee_rate_max': instance.feeRateMax,
      'fee_rate_trim': instance.feeRateTrim,
      'home': instance.home,
      'id': instance.id,
      'max_staking': instance.maxStaking,
      'mod': instance.mod,
      'name': instance.name,
      'node_id': instance.nodeId,
      'pic': instance.pic,
      'reward': instance.reward,
      'reward_history': instance.rewardHistory,
      'reward_rate': instance.rewardRate,
      'sign_rate': instance.signRate,
      'staking': instance.staking,
      'status': instance.status,
      'updated_at': instance.updatedAt,
    };
