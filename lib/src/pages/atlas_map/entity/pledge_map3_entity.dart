import 'package:json_annotation/json_annotation.dart';

import 'enum_atlas_type.dart';
  
part 'pledge_map3_entity.g.dart';


@JsonSerializable()
  class PledgeMap3Entity extends Object {

  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'gas_limit')
  int gasLimit;

  @JsonKey(name: 'nonce')
  int nonce;

  @JsonKey(name: 'payload')
  PledgeMap3Payload payload;

  @JsonKey(name: 'price')
  String price;

  @JsonKey(name: 'raw_tx')
  String rawTx;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'type')
  AtlasActionType type;

  PledgeMap3Entity(this.amount,this.from,this.gasLimit,this.nonce,this.payload,this.price,this.rawTx,this.to,this.type,);
  PledgeMap3Entity.onlyType(this.type);

  factory PledgeMap3Entity.fromJson(Map<String, dynamic> srcJson) => _$PledgeMap3EntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PledgeMap3EntityToJson(this);

}

  
@JsonSerializable()
  class PledgeMap3Payload extends Object {

  @JsonKey(name: 'map3_node_id')
  String map3NodeId;

//  取消节点时不用传。抵押量
  @JsonKey(name: 'staking')
  String staking;

  PledgeMap3Payload(this.map3NodeId,this.staking,);

  factory PledgeMap3Payload.fromJson(Map<String, dynamic> srcJson) => _$PledgeMap3PayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PledgeMap3PayloadToJson(this);

}

  
