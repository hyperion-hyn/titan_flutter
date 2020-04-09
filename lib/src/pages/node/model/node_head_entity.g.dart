// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_head_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeHeadEntity _$NodeHeadEntityFromJson(Map<String, dynamic> json) {
  return NodeHeadEntity(
    (json['lastRecordMessage'] as List)?.map((e) => e as String)?.toList(),
    json['message'] as String,
    json['node'] == null
        ? null
        : Node.fromJson(json['node'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NodeHeadEntityToJson(NodeHeadEntity instance) =>
    <String, dynamic>{
      'lastRecordMessage': instance.lastRecordMessage,
      'message': instance.message,
      'node': instance.node,
    };

Node _$NodeFromJson(Map<String, dynamic> json) {
  return Node(
    json['name'] as String,
    json['content'] as String,
    json['pic'] as String,
  );
}

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'name': instance.name,
      'content': instance.content,
      'pic': instance.pic,
    };
