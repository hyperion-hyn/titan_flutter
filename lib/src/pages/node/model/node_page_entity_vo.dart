

import 'dart:convert';

import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_head_entity.dart';

import 'package:json_annotation/json_annotation.dart';

part 'node_page_entity_vo.g.dart';


@JsonSerializable()
class NodePageEntityVo extends Object {

  NodeHeadEntity nodeHeadEntity;

  List<ContractNodeItem> contractNodeList;

  NodePageEntityVo(this.nodeHeadEntity,this.contractNodeList,);

  factory NodePageEntityVo.fromJson(Map<String, dynamic> srcJson) => _$NodePageEntityVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodePageEntityVoToJson(this);

  bool isEqual(NodePageEntityVo entityVo){
    return json.encode(this.toJson()) == json.encode(entityVo.toJson());
  }

  NodePageEntityVo clone(){
    return NodePageEntityVo.fromJson(json.decode(json.encode(this.toJson())));
  }

}