import 'package:json_annotation/json_annotation.dart';

import 'atlas_node_entity.dart';
import 'enum_atlas_type.dart';

part 'map3_info_entity.g.dart';


@JsonSerializable()
  class Map3InfoEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'atlas')
  List<AtlasNodeEntity> atlas;

  @JsonKey(name: 'contact')
  String contact;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'creator')
  String creator;

  @JsonKey(name: 'describe')
  String describe;

  @JsonKey(name: 'end_time')
  String endTime;

  @JsonKey(name: 'fee_rate')
  String feeRate;

  @JsonKey(name: 'home')
  String home;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'join')
  NodeJoinType join;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'parent_node_id')
  String parentNodeId;

  @JsonKey(name: 'pic')
  String pic;

  @JsonKey(name: 'provider')
  String provider;

  @JsonKey(name: 'region')
  String region;

  @JsonKey(name: 'reward')
  String reward;

  @JsonKey(name: 'reward_mine')
  String rewardMine;

  @JsonKey(name: 'reward_rate')
  String rewardRate;

  @JsonKey(name: 'staking')
  String staking;

  @JsonKey(name: 'staking_mine')
  String stakingMine;

  @JsonKey(name: 'start_time')
  String startTime;

  @JsonKey(name: 'status')
  NodeStatus status;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  Map3InfoEntity(this.address,this.atlas,this.contact,this.createdAt,this.creator,this.describe,this.endTime,this.feeRate,this.home,this.id,this.join,this.name,this.nodeId,this.parentNodeId,this.pic,this.provider,this.region,this.reward,this.rewardMine,this.rewardRate,this.staking,this.stakingMine,this.startTime,this.status,this.updatedAt,);

  factory Map3InfoEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3InfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3InfoEntityToJson(this);

}


  
