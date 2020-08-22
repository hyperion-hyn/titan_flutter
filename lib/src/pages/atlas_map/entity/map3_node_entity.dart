import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
  
part 'map3_node_entity.g.dart';


@JsonSerializable()
  class Map3NodeEntity extends Object {

  @JsonKey(name: 'address')
  String address;

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
  int feeRate;

  @JsonKey(name: 'home')
  String home;

  @JsonKey(name: 'id')
  int id;

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
  int reward;

  @JsonKey(name: 'reward_rate')
  int rewardRate;

  @JsonKey(name: 'staking')
  int staking;

  @JsonKey(name: 'start_time')
  String startTime;

  @JsonKey(name: 'status')
  AtlasStatus status;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  Map3NodeEntity(this.address,this.contact,this.createdAt,this.creator,this.describe,this.endTime,this.feeRate,this.home,this.id,this.name,this.nodeId,this.parentNodeId,this.pic,this.provider,this.region,this.reward,this.rewardRate,this.staking,this.startTime,this.status,this.updatedAt,);

  factory Map3NodeEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3NodeEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3NodeEntityToJson(this);

}

  
