import 'package:json_annotation/json_annotation.dart';

part 'node_head_entity.g.dart';


@JsonSerializable()
class NodeHeadEntity extends Object {

  @JsonKey(name: 'instanceCount')
  int instanceCount;

  @JsonKey(name: 'lastRecordMessage')
  List<String> lastRecordMessage;// use it will get exception in cache

  @JsonKey(name: 'message')
  String message;

  @JsonKey(name: 'node')
  Node node;

  NodeHeadEntity(this.instanceCount,this.lastRecordMessage,this.message,this.node,);

  NodeHeadEntity.nullEntity();

  factory NodeHeadEntity.fromJson(Map<String, dynamic> srcJson) => _$NodeHeadEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeHeadEntityToJson(this);

}


@JsonSerializable()
class Node extends Object {

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'version')
  String version;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'pic')
  String pic;

  Node(this.name, this.version, this.content,this.pic,);

  factory Node.fromJson(Map<String, dynamic> srcJson) => _$NodeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeToJson(this);

}