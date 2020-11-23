

import 'dart:convert';

import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
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

@JsonSerializable()
class Map3PageEntityVo extends Object {

  NodeHeadEntity nodeHeadEntity;

  List<Map3InfoEntity> contractNodeList;

  Map3PageEntityVo(this.nodeHeadEntity,this.contractNodeList,);

  factory Map3PageEntityVo.fromJson(Map<String, dynamic> srcJson) => _$Map3PageEntityVoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3PageEntityVoToJson(this);

  bool isEqual(Map3PageEntityVo entityVo){
    return json.encode(this.toJson()) == json.encode(entityVo.toJson());
  }

  Map3PageEntityVo clone(){
    return Map3PageEntityVo.fromJson(json.decode(json.encode(this.toJson())));
  }

}