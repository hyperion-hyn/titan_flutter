import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'node_item.dart';

part 'node_product_page_vo.g.dart';


@JsonSerializable()
class NodeProductPageVo extends Object {

  @JsonKey(name: 'nodeItemList')
  List<NodeItem> nodeItemList;

  NodeProductPageVo(this.nodeItemList,);

  factory NodeProductPageVo.fromJson(Map<String, dynamic> srcJson) => _$NodeProductPageVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeProductPageVoToJson(this);

  bool isEqual(NodeProductPageVo entityVo){
    return json.encode(this.toJson()) == json.encode(entityVo.toJson());
  }

}


