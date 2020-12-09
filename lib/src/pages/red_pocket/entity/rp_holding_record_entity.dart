import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_holding_record_entity.g.dart';


@JsonSerializable()
  class RpHoldingRecordEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'burning')
  int burning;

  @JsonKey(name: 'circulation')
  int circulation;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'from')
  int from;

  @JsonKey(name: 'highest_level')
  int highestLevel;

  @JsonKey(name: 'holding')
  int holding;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'state')
  int state;

  @JsonKey(name: 'to')
  int to;

  @JsonKey(name: 'total_holding')
  int totalHolding;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'withdraw')
  int withdraw;

  RpHoldingRecordEntity(this.address,this.burning,this.circulation,this.createdAt,this.from,this.highestLevel,this.holding,this.id,this.state,this.to,this.totalHolding,this.txHash,this.type,this.updatedAt,this.withdraw,);

  factory RpHoldingRecordEntity.fromJson(Map<String, dynamic> srcJson) => _$RpHoldingRecordEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpHoldingRecordEntityToJson(this);

}

  
