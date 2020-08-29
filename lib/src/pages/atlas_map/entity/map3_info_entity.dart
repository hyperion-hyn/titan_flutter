import 'package:json_annotation/json_annotation.dart';

import 'atlas_info_entity.dart';
import 'map3_atlas_entity.dart';
import 'user_map3_entity.dart';

part 'map3_info_entity.g.dart';


@JsonSerializable()
class Map3InfoEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'atlas')
  AtlasInfoEntity atlas;

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

  @JsonKey(name: 'mine')
  UserMap3Entity mine;

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

  @JsonKey(name: 'relative')
  Map3AtlasEntity relative;

  @JsonKey(name: 'reward_history')
  String rewardHistory;

  @JsonKey(name: 'reward_rate')
  String rewardRate;

  @JsonKey(name: 'staking')
  String staking;

  @JsonKey(name: 'start_time')
  String startTime;

  @JsonKey(name: 'status')
  int status;//Map3InfoStatus

  @JsonKey(name: 'updated_at')
  String updatedAt;

  Map3InfoEntity(this.address,this.atlas,this.contact,this.createdAt,this.creator,this.describe,this.endTime,this.feeRate,this.home,this.id,this.mine,this.name,this.nodeId,this.parentNodeId,this.pic,this.provider,this.region,this.relative,this.rewardHistory,this.rewardRate,this.staking,this.startTime,this.status,this.updatedAt,);

  Map3InfoEntity.onlyId(this.id);

  factory Map3InfoEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3InfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3InfoEntityToJson(this);

}