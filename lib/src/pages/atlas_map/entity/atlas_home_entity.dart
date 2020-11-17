import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';

part 'atlas_home_entity.g.dart';

@JsonSerializable()
class AtlasHomeEntity extends Object {
  @JsonKey(name: 'info')
  CommitteeInfoEntity info;

  @JsonKey(name: 'my_nodes')
  List<AtlasHomeNode> atlasHomeNodeList;

  @JsonKey(name: 'points')
  String points;

  @JsonKey(name: 'map3_num')
  int map3Count;

  AtlasHomeEntity(
    this.info,
    this.atlasHomeNodeList,
    this.points,
    this.map3Count,
  );

  factory AtlasHomeEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$AtlasHomeEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AtlasHomeEntityToJson(this);
}

@JsonSerializable()
class AtlasHomeNode extends Object {
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

  @JsonKey(name: 'mod')
  int mod;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'pic')
  String pic;

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

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  AtlasHomeNode(
    this.address,
    this.blockNum,
    this.blsKey,
    this.blsSign,
    this.contact,
    this.createdAt,
    this.creator,
    this.describe,
    this.feeRate,
    this.feeRateMax,
    this.feeRateTrim,
    this.home,
    this.id,
    this.maxStaking,
    this.mod,
    this.name,
    this.nodeId,
    this.pic,
    this.reward,
    this.rewardHistory,
    this.rewardRate,
    this.signRate,
    this.staking,
    this.status,
    this.updatedAt,
  );

  factory AtlasHomeNode.fromJson(Map<String, dynamic> srcJson) =>
      _$AtlasHomeNodeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AtlasHomeNodeToJson(this);
}
