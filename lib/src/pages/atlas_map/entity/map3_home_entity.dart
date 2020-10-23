import 'package:json_annotation/json_annotation.dart';
import 'map3_info_entity.dart';

part 'map3_home_entity.g.dart';

@JsonSerializable()
class Map3HomeEntity extends Object {
  @JsonKey(name: 'my_nodes')
  List<Map3InfoEntity> myNodes;

  @JsonKey(name: 'new_start_nodes')
  List<Map3InfoEntity> newStartNodes;

  @JsonKey(name: 'points')
  String points;

  Map3HomeEntity(
    this.myNodes,
    this.newStartNodes,
    this.points,
  );

  factory Map3HomeEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$Map3HomeEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3HomeEntityToJson(this);
}
