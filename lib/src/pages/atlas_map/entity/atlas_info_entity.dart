import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_node_entity.dart';

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
  int feeRate;

  @JsonKey(name: 'fee_rate_max')
  int feeRateMax;

  @JsonKey(name: 'fee_rate_trim')
  int feeRateTrim;

  @JsonKey(name: 'home')
  String home;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'join')
  int join;

  @JsonKey(name: 'max_staking')
  int maxStaking;

  @JsonKey(name: 'my_map3')
  List<Map3NodeEntity> myMap3;

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
  int status;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  AtlasInfoEntity(this.address,this.blockNum,this.blsKey,this.blsSign,this.contact,this.createdAt,this.creator,this.describe,this.feeRate,this.feeRateMax,this.feeRateTrim,this.home,this.id,this.join,this.maxStaking,this.myMap3,this.name,this.nodeId,this.pic,this.reward,this.rewardRate,this.signRate,this.staking,this.status,this.type,this.updatedAt,);

  factory AtlasInfoEntity.fromJson(Map<String, dynamic> srcJson) => _$AtlasInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AtlasInfoEntityToJson(this);

}


  
