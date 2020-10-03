import 'package:json_annotation/json_annotation.dart';

import 'enum_atlas_type.dart';
  
part 'create_atlas_entity.g.dart';


@JsonSerializable()
  class CreateAtlasEntity extends Object {

  // hyn数量
  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'gas_limit')
  int gasLimit;

  @JsonKey(name: 'nonce')
  int nonce;

  @JsonKey(name: 'payload')
  CreateAtlasPayload payload;

  @JsonKey(name: 'price')
  String price;

  //签名后raw，hex字符串
  @JsonKey(name: 'raw_tx')
  String rawTx;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'type')
  AtlasActionType type;

  CreateAtlasEntity(this.amount,this.from,this.gasLimit,this.nonce,this.payload,this.price,this.rawTx,this.to,this.type,);

  factory CreateAtlasEntity.fromJson(Map<String, dynamic> srcJson) => _$CreateAtlasEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CreateAtlasEntityToJson(this);
}

  /*

  {
  bls_key	string
  bls_sign	string
  connect	string
  安全联系方式

  describe	string
  描述

  fee_rate	number
  费率

  fee_rate_max	number
  最大费率

  fee_rate_trim	number
  费率幅度

  home	string
  网址

  map3_node_id	string
  抵押的map3节点号

  max_pledge	number
  最大抵押量

  name	string
  名称

  node_id	string
  节点号

  pic	string
  节点头像url

  }
  */

@JsonSerializable()
  class CreateAtlasPayload extends Object {

  @JsonKey(name: 'bls_key')
  String blsKey;

  @JsonKey(name: 'bls_sign')
  String blsSign;

  @JsonKey(name: 'contact')
  String contact;

  @JsonKey(name: 'describe')
  String describe;

  @JsonKey(name: 'fee_rate')
  String feeRate;

  @JsonKey(name: 'fee_rate_max')
  String feeRateMax;

  @JsonKey(name: 'fee_rate_trim')
  String feeRateTrim;

  @JsonKey(name: 'home')
  String home;

  @JsonKey(name: 'map3_address')
  String map3Address;

  @JsonKey(name: 'max_staking')
  String maxStaking;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'atlas_address')
  String atlasAddress;

  @JsonKey(name: 'pic')
  String pic;

  CreateAtlasPayload(this.blsKey,this.blsSign,this.contact,this.describe,this.feeRate,this.feeRateMax,this.feeRateTrim,this.home,this.map3Address,this.maxStaking,this.name,this.nodeId,this.atlasAddress,this.pic,);

  factory CreateAtlasPayload.fromJson(Map<String, dynamic> srcJson) => _$CreateAtlasPayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CreateAtlasPayloadToJson(this);

}

  
