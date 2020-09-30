import 'package:json_annotation/json_annotation.dart';

import 'enum_atlas_type.dart';
  
part 'create_map3_entity.g.dart';


@JsonSerializable()
  class CreateMap3Entity extends Object {

  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'gas_limit')
  int gasLimit;

  @JsonKey(name: 'nonce')
  int nonce;

  @JsonKey(name: 'payload')
  CreateMap3Payload payload;

  @JsonKey(name: 'price')
  String price;

  @JsonKey(name: 'raw_tx')
  String rawTx;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'type')
  AtlasActionType type;

  CreateMap3Entity(this.amount,this.from,this.gasLimit,this.nonce,this.payload,this.price,this.rawTx,this.to,this.type,);
  CreateMap3Entity.onlyType(this.type);

  factory CreateMap3Entity.fromJson(Map<String, dynamic> srcJson) => _$CreateMap3EntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CreateMap3EntityToJson(this);

}


  /*

  {
  connect	string
  安全联系方式

  describe	string
  描述

  fee_rate	number
  费率

  home	string
  网址

  name	string
  名称

  node_id	string
  节点号

  parent_node_id	string
  节点分裂时才需要

  pic	string
  节点头像url

  provider	string
  服务商id

  region	string
  区域id

  staking	number
  抵押量

  }
  */


@JsonSerializable()
  class CreateMap3Payload extends Object {

  @JsonKey(name: 'connect')
  String connect;

  @JsonKey(name: 'describe')
  String describe;

  @JsonKey(name: 'fee_rate')
  String feeRate;

  @JsonKey(name: 'home')
  String home;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'parent_node_id')
  String parentNodeId;

  @JsonKey(name: 'pic')
  String pic;

  @JsonKey(name: 'pledge')
  int pledge;

  @JsonKey(name: 'provider')
  String provider;

  @JsonKey(name: 'region')
  String region;

  @JsonKey(name: 'staking')
  String staking;

  CreateMap3Payload(this.connect,this.describe,this.feeRate,this.home,this.name,this.nodeId,this.parentNodeId,this.pic,this.pledge,this.provider,this.region,this.staking);
  CreateMap3Payload.onlyNodeId(this.nodeId);

  factory CreateMap3Payload.fromJson(Map<String, dynamic> srcJson) => _$CreateMap3PayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CreateMap3PayloadToJson(this);

}

  
