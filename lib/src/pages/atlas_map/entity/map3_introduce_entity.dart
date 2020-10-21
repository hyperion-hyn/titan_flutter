import 'package:json_annotation/json_annotation.dart';

part 'map3_introduce_entity.g.dart';

@JsonSerializable()
class Map3IntroduceEntity extends Object {
  @JsonKey(name: 'create_min')
  String createMin;

  @JsonKey(name: 'days')
  int days;

  @JsonKey(name: 'fee_max')
  String feeMax;

  @JsonKey(name: 'fee_min')
  String feeMin;

  @JsonKey(name: 'start_min')
  String startMin;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'version')
  String version;

  String get name => "${this?.title ?? "Map3"}云节点 (${this?.version ?? "v1.0"})";

  Map3IntroduceEntity(
    this.createMin,
    this.days,
    this.feeMax,
    this.feeMin,
    this.startMin,
    this.title,
    this.version,
  );

  factory Map3IntroduceEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3IntroduceEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3IntroduceEntityToJson(this);
}
