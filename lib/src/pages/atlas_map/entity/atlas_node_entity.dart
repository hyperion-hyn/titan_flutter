
import 'package:json_annotation/json_annotation.dart';

import 'enum_atlas_type.dart';

part 'atlas_node_entity.g.dart';

@deprecated
@JsonSerializable()
class AtlasNodeEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'block_num')
  int blockNum;

  @JsonKey(name: 'bls_key')
  String blsKey;

  @JsonKey(name: 'bls_sign')
  String blsSign;

  @JsonKey(name: 'contact')
  String contact;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'creator')
  String creator;

  @JsonKey(name: 'describe')
  String describe;

  @JsonKey(name: 'fee_rate')
  String feeRate;

  @JsonKey(name: 'fee_rate_max')
  String feeRateMax;

  @JsonKey(name: 'fee_rate_trim')
  String feeRateTrim;

  @JsonKey(name: 'home')
  String home;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'max_staking')
  int maxStaking;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'pic')
  String pic;

  @JsonKey(name: 'reward')
  int reward;

  @JsonKey(name: 'reward_rate')
  int rewardRate;

  @JsonKey(name: 'sign_rate')
  int signRate;

  @JsonKey(name: 'staking')
  int staking;

  @JsonKey(name: 'status')
  AtlasInfoStatus status;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  AtlasNodeEntity(this.address,this.blockNum,this.blsKey,this.blsSign,this.contact,this.createdAt,this.creator,this.describe,this.feeRate,this.feeRateMax,this.feeRateTrim,this.home,this.id,this.maxStaking,this.name,this.nodeId,this.pic,this.reward,this.rewardRate,this.signRate,this.staking,this.status,this.updatedAt,);

  factory AtlasNodeEntity.fromJson(Map<String, dynamic> srcJson) => _$AtlasNodeEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AtlasNodeEntityToJson(this);

}
