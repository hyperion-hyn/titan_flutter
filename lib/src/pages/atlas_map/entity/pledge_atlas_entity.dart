import 'package:json_annotation/json_annotation.dart';

import 'enum_atlas_type.dart';
  
part 'pledge_atlas_entity.g.dart';


@JsonSerializable()
  class PledgeAtlasEntity extends Object {

  @JsonKey(name: 'value')
  String value;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'gas_limit')
  int gasLimit;

  @JsonKey(name: 'nonce')
  int nonce;

  @JsonKey(name: 'payload')
  PledgeAtlasPayload payload;

  @JsonKey(name: 'gas_price')
  String gasPrice;

  @JsonKey(name: 'raw_tx')
  String rawTx;

  @JsonKey(name: 'to')
  String to;


  @JsonKey(name: 'type')
  AtlasActionType type;

  PledgeAtlasEntity(this.value,this.from,this.gasLimit,this.nonce,this.payload,this.gasPrice,this.rawTx,this.to,this.type,);

  factory PledgeAtlasEntity.fromJson(Map<String, dynamic> srcJson) => _$PledgeAtlasEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PledgeAtlasEntityToJson(this);

}

  
@JsonSerializable()
  class PledgeAtlasPayload extends Object {

  @JsonKey(name: 'atlas_address')
  String atlasAddress;

  @JsonKey(name: 'map3_address')
  String map3Address;

  PledgeAtlasPayload(this.atlasAddress,this.map3Address,);

  factory PledgeAtlasPayload.fromJson(Map<String, dynamic> srcJson) => _$AtlasPayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AtlasPayloadToJson(this);

}

  
