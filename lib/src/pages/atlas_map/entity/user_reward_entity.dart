import 'package:json_annotation/json_annotation.dart'; 
  
part 'user_reward_entity.g.dart';


@JsonSerializable()
  class UserRewardEntity extends Object {

  @JsonKey(name: 'node_num')
  int nodeNum;

  @JsonKey(name: 'reward')
  int reward;

  UserRewardEntity(this.nodeNum,this.reward,);

  factory UserRewardEntity.fromJson(Map<String, dynamic> srcJson) => _$UserRewardEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserRewardEntityToJson(this);

}

  
