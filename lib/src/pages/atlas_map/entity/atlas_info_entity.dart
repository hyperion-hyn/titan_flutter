import 'package:json_annotation/json_annotation.dart';

import 'map3_info_entity.dart';

part 'atlas_info_entity.g.dart';


@JsonSerializable()
class AtlasInfoEntity extends Object {

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
  String maxStaking;

  @JsonKey(name: 'my_map3')
  List<Map3InfoEntity> myMap3;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'pic')
  String pic;

  @JsonKey(name: 'rank')
  int rank;

  @JsonKey(name: 'reward')
  String reward;

  @JsonKey(name: 'reward_history')
  String rewardHistory;

  @JsonKey(name: 'reward_rate')
  String rewardRate;

  @JsonKey(name: 'sign_rate')
  String signRate;

  @JsonKey(name: 'staking')
  String staking;

  @JsonKey(name: 'staking_creator')
  String stakingCreator;

  ///AtlasNodeStatus
  @JsonKey(name: 'status')
  int status;

  ///AtlasNodeType
  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  AtlasInfoEntity(this.address,this.blockNum,this.blsKey,this.blsSign,this.contact,this.createdAt,this.creator,this.describe,this.feeRate,this.feeRateMax,this.feeRateTrim,this.home,this.id,this.maxStaking,this.myMap3,this.name,this.nodeId,this.pic,this.rank,this.reward,this.rewardHistory,this.rewardRate,this.signRate,this.staking,this.stakingCreator,this.status,this.type,this.updatedAt,);

  AtlasInfoEntity.onlyId(this.id);

  factory AtlasInfoEntity.fromJson(Map<String, dynamic> srcJson) => _$AtlasInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AtlasInfoEntityToJson(this);

}