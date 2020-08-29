import 'package:json_annotation/json_annotation.dart';

part 'map3_atlas_entity.g.dart';


@JsonSerializable()
class Map3AtlasEntity extends Object {

  @JsonKey(name: 'atlas_node_id')
  String atlasNodeId;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'creator')
  int creator;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'map3_node_id')
  String map3NodeId;

  @JsonKey(name: 'reward')
  String reward;

  @JsonKey(name: 'staking')
  String staking;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  Map3AtlasEntity(this.atlasNodeId,this.createdAt,this.creator,this.id,this.map3NodeId,this.reward,this.staking,this.status,this.updatedAt,);

  factory Map3AtlasEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3AtlasEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3AtlasEntityToJson(this);

}


