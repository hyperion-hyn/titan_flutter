import 'package:json_annotation/json_annotation.dart';

part 'node_share_entity.g.dart';


@JsonSerializable()
class NodeShareEntity extends Object {

  @JsonKey(name: 'a')
  String a;

  @JsonKey(name: 'b')
  String b;

  @JsonKey(name: 'c')
  bool c;

  NodeShareEntity(this.a,this.b,this.c,);

  factory NodeShareEntity.fromJson(Map<String, dynamic> srcJson) => _$NodeShareEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeShareEntityToJson(this);

}


