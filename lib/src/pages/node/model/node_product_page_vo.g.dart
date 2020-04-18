// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_product_page_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeProductPageVo _$NodeProductPageVoFromJson(Map<String, dynamic> json) {
  return NodeProductPageVo(
    (json['nodeItemList'] as List)
        ?.map((e) =>
            e == null ? null : NodeItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NodeProductPageVoToJson(NodeProductPageVo instance) =>
    <String, dynamic>{
      'nodeItemList': instance.nodeItemList,
    };
