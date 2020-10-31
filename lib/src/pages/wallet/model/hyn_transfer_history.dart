import 'package:json_annotation/json_annotation.dart';

part 'hyn_transfer_history.g.dart';

@JsonSerializable()
class HynTransferHistory extends Object {
  @JsonKey(name: 'atlas_address')
  String atlasAddress;

  @JsonKey(name: 'block_hash')
  String blockHash;

  @JsonKey(name: 'block_num')
  int blockNum;

  @JsonKey(name: 'contract_address')
  String contractAddress;

  @JsonKey(name: 'created_at')
  int createdAt;

  @JsonKey(name: 'data')
  String data;

  @JsonKey(name: 'data_decoded')
  Map<String, dynamic> dataDecoded;

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

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'logs_decoded')
  LogsDecoded logsDecoded;

  @JsonKey(name: 'map3_address')
  String map3Address;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'nonce')
  int nonce;

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
  int updatedAt;

  @JsonKey(name: 'value')
  String value;

  HynTransferHistory(
    this.atlasAddress,
    this.blockHash,
    this.blockNum,
    this.contractAddress,
    this.createdAt,
    this.data,
    this.dataDecoded,
    this.epoch,
    this.from,
    this.gasLimit,
    this.gasPrice,
    this.gasUsed,
    this.id,
    this.logsDecoded,
    this.map3Address,
    this.name,
    this.nonce,
    this.pic,
    this.status,
    this.timestamp,
    this.to,
    this.transactionIndex,
    this.txHash,
    this.type,
    this.updatedAt,
    this.value,
  );

  factory HynTransferHistory.fromJson(Map<String, dynamic> srcJson) => _$HynTransferHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HynTransferHistoryToJson(this);
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

  DataDecoded(
    this.operatorAddress,
    this.description,
    this.commission,
    this.nodePubKey,
    this.nodeKeySig,
    this.amount,
  );

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

  Description(
    this.name,
    this.identity,
    this.website,
    this.securityContact,
    this.details,
  );

  factory Description.fromJson(Map<String, dynamic> srcJson) => _$DescriptionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DescriptionToJson(this);
}

@JsonSerializable()
class LogsDecoded extends Object {
  @JsonKey(name: 'rewards')
  List<Rewards> rewards;

  @JsonKey(name: 'topics')
  String topics;

  LogsDecoded(
    this.rewards,
    this.topics,
  );

  factory LogsDecoded.fromJson(Map<String, dynamic> srcJson) => _$LogsDecodedFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LogsDecodedToJson(this);
}

@JsonSerializable()
class Rewards extends Object {
  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'amount')
  String amount;

  Rewards(
    this.address,
    this.amount,
  );

  factory Rewards.fromJson(Map<String, dynamic> srcJson) => _$RewardsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RewardsToJson(this);
}
