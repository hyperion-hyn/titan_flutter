// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_page_entity_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodePageEntityVo _$NodePageEntityVoFromJson(Map<String, dynamic> json) {
  return NodePageEntityVo(
    json['nodeHeadEntity'] == null
        ? null
        : NodeHeadEntity.fromJson(
            json['nodeHeadEntity'] as Map<String, dynamic>),
    (json['contractNodeList'] as List)
        ?.map((e) => e == null
            ? null
            : ContractNodeItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NodePageEntityVoToJson(NodePageEntityVo instance) =>
    <String, dynamic>{
      'nodeHeadEntity': instance.nodeHeadEntity,
      'contractNodeList': instance.contractNodeList,
    };


Map3PageEntityVo _$Map3PageEntityVoFromJson(Map<String, dynamic> json) {
  return Map3PageEntityVo(
    json['nodeHeadEntity'] == null
        ? null
        : NodeHeadEntity.fromJson(
        json['nodeHeadEntity'] as Map<String, dynamic>),
    (json['contractNodeList'] as List)
        ?.map((e) => e == null
        ? null
        : Map3InfoEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$Map3PageEntityVoToJson(Map3PageEntityVo instance) =>
    <String, dynamic>{
      'nodeHeadEntity': instance.nodeHeadEntity,
      'contractNodeList': instance.contractNodeList,
    };