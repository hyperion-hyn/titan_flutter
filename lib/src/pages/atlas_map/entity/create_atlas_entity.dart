import 'package:json_annotation/json_annotation.dart';

import 'enum_atlas_type.dart';
  
part 'create_atlas_entity.g.dart';


@JsonSerializable()
  class CreateAtlasEntity extends Object {

  @JsonKey(name: 'amount')
  int amount;

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

  
@JsonSerializable()
  class CreateAtlasPayload extends Object {

  @JsonKey(name: 'bls_key')
  String blsKey;

  @JsonKey(name: 'bls_sign')
  String blsSign;

  @JsonKey(name: 'connect')
  String connect;

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

  @JsonKey(name: 'map3_node_id')
  String map3NodeId;

  @JsonKey(name: 'max_pledge')
  int maxPledge;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'pic')
  String pic;

  CreateAtlasPayload(this.blsKey,this.blsSign,this.connect,this.describe,this.feeRate,this.feeRateMax,this.feeRateTrim,this.home,this.map3NodeId,this.maxPledge,this.name,this.nodeId,this.pic,);

  factory CreateAtlasPayload.fromJson(Map<String, dynamic> srcJson) => _$CreateAtlasPayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CreateAtlasPayloadToJson(this);

}

  
