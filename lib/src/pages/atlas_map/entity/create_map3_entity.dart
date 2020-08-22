import 'package:json_annotation/json_annotation.dart';

import 'enum_atlas_type.dart';
  
part 'create_map3_entity.g.dart';


@JsonSerializable()
  class CreateMap3Entity extends Object {

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'gas_limit')
  int gasLimit;

  @JsonKey(name: 'nonce')
  int nonce;

  @JsonKey(name: 'payload')
  CreateMap3Payload payload;

  @JsonKey(name: 'price')
  int price;

  @JsonKey(name: 'raw_tx')
  String rawTx;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'type')
  AtlasType type;

  CreateMap3Entity(this.amount,this.from,this.gasLimit,this.nonce,this.payload,this.price,this.rawTx,this.to,this.type,);

  factory CreateMap3Entity.fromJson(Map<String, dynamic> srcJson) => _$CreateMap3EntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CreateMap3EntityToJson(this);

}

  
@JsonSerializable()
  class CreateMap3Payload extends Object {

  @JsonKey(name: 'connect')
  String connect;

  @JsonKey(name: 'describe')
  String describe;

  @JsonKey(name: 'fee_rate')
  int feeRate;

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

  CreateMap3Payload(this.connect,this.describe,this.feeRate,this.home,this.name,this.nodeId,this.parentNodeId,this.pic,this.pledge,this.provider,this.region,);

  factory CreateMap3Payload.fromJson(Map<String, dynamic> srcJson) => _$CreateMap3PayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CreateMap3PayloadToJson(this);

}

  
