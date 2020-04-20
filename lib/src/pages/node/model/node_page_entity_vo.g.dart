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
