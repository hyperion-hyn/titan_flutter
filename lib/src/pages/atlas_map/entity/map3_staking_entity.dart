import 'package:json_annotation/json_annotation.dart';
import 'map3_info_entity.dart';

part 'map3_staking_entity.g.dart';

@JsonSerializable()
class Map3StakingEntity extends Object {
  @JsonKey(name: 'map3_nodes')
  List<Map3InfoEntity> map3Nodes;

  @JsonKey(name: 'can_staking_num')
  int canStakingNum;


  Map3StakingEntity(
      this.map3Nodes,
      this.canStakingNum,
      );


  factory Map3StakingEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3StakingEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3StakingEntityToJson(this);
}
