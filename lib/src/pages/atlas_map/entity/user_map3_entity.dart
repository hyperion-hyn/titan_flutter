import 'package:json_annotation/json_annotation.dart';

part 'user_map3_entity.g.dart';


@JsonSerializable()
class UserMap3Entity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'created_at')
  String createdAt;

  ///NodeJoinType
  @JsonKey(name: 'creator')
  int creator;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'reward')
  String reward;

  @JsonKey(name: 'reward_history')
  String rewardHistory;

  @JsonKey(name: 'staking')
  String staking;

  ///UserMap3Status
  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  UserMap3Entity(this.address,this.createdAt,this.creator,this.id,this.nodeId,this.reward,this.rewardHistory,this.staking,this.status,this.updatedAt,);

  UserMap3Entity.onlyId(this.id);
  UserMap3Entity.onlyCreator(this.creator);

  factory UserMap3Entity.fromJson(Map<String, dynamic> srcJson) => _$UserMap3EntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserMap3EntityToJson(this);

}


