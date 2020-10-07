import 'package:json_annotation/json_annotation.dart'; 
  
part 'map3_staking_log_entity.g.dart';


@JsonSerializable()
  class Map3StakingLogEntity extends Object {

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'map3_address')
  String map3Address;

  @JsonKey(name: 'staking')
  int staking;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'user_address')
  String userAddress;

  Map3StakingLogEntity(this.createdAt,this.id,this.map3Address,this.staking,this.updatedAt,this.userAddress,);

  factory Map3StakingLogEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3StakingLogEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3StakingLogEntityToJson(this);

}

  
