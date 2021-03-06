import 'package:json_annotation/json_annotation.dart'; 
  
part 'map3_tx_log_entity.g.dart';


@JsonSerializable()
  class Map3TxLogEntity extends Object {

  @JsonKey(name: 'atlas_address')
  String atlasAddress;

  @JsonKey(name: 'block_hash')
  String blockHash;

  @JsonKey(name: 'block_num')
  int blockNum;

  @JsonKey(name: 'contract_address')
  String contractAddress;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'data')
  String data;

  @JsonKey(name: 'dataDecoded')
  DataDecoded dataDecoded;

  @JsonKey(name: 'epoch')
  int epoch;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'gas_limit')
  int gasLimit;

  @JsonKey(name: 'gas_price')
  String gasPrice;

  @JsonKey(name: 'gas_used')
  int gasUsed;

  @JsonKey(name: 'handle_status')
  int handleStatus;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'map3_address')
  String map3Address;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'nonce')
  int nonce;

  @JsonKey(name: 'payload')
  String payload;

  @JsonKey(name: 'pic')
  String pic;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'timestamp')
  int timestamp;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'transaction_index')
  int transactionIndex;

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'value')
  String value;

  Map3TxLogEntity(this.atlasAddress,this.blockHash,this.blockNum,this.contractAddress,this.createdAt,this.data,this.dataDecoded,this.epoch,this.from,this.gasLimit,this.gasPrice,this.gasUsed,this.handleStatus,this.id,this.map3Address,this.name,this.nonce,this.payload,this.pic,this.status,this.timestamp,this.to,this.transactionIndex,this.txHash,this.type,this.updatedAt,this.value,);

  factory Map3TxLogEntity.fromJson(Map<String, dynamic> srcJson) => _$Map3TxLogEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$Map3TxLogEntityToJson(this);

}


@JsonSerializable()
class DataDecoded extends Object {

  @JsonKey(name: 'operatorAddress')
  String operatorAddress;

  @JsonKey(name: 'description')
  Description description;

  @JsonKey(name: 'commission')
  String commission;

  @JsonKey(name: 'nodePubKey')
  String nodePubKey;

  @JsonKey(name: 'nodeKeySig')
  String nodeKeySig;

  @JsonKey(name: 'amount')
  String amount;

  DataDecoded(this.operatorAddress,this.description,this.commission,this.nodePubKey,this.nodeKeySig,this.amount,);

  factory DataDecoded.fromJson(Map<String, dynamic> srcJson) => _$DataDecodedFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DataDecodedToJson(this);

}


@JsonSerializable()
class Description extends Object {

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'identity')
  String identity;

  @JsonKey(name: 'website')
  String website;

  @JsonKey(name: 'securityContact')
  String securityContact;

  @JsonKey(name: 'details')
  String details;

  Description(this.name,this.identity,this.website,this.securityContact,this.details,);

  factory Description.fromJson(Map<String, dynamic> srcJson) => _$DescriptionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DescriptionToJson(this);

}




  
