import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

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

  @JsonKey(name: 'payload')
  TransferPayload payload;

  @JsonKey(name: 'internal_trans')
  List<InternalTransactions> internalTransactions;

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
    this.payload,
    this.internalTransactions,
  );

  factory HynTransferHistory.fromJson(Map<String, dynamic> srcJson) => _$HynTransferHistoryFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HynTransferHistoryToJson(this);

  BigInt getAllContractValue(){
    BigInt value = BigInt.from(0);
    internalTransactions.forEach((element) {
      value += BigInt.parse(element.value);
    });
    return value;
  }

}

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

class TransferPayload extends Object {

  @JsonKey(name: 'Delegator')
  String delegator;

  @JsonKey(name: 'Map3Node')
  String map3Node;

  @JsonKey(name: 'Amount')
  String amount;

  @JsonKey(name: 'Reward')
  String reward;

  TransferPayload(this.delegator,this.map3Node,this.amount,this.reward,);

  factory TransferPayload.fromJson(Map<String, dynamic> srcJson) => _$TransferPayloadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TransferPayloadToJson(this);

}

class InternalTransactions extends Object {

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'log_index')
  int logIndex;

  @JsonKey(name: 'from')
  String from;

  @JsonKey(name: 'to')
  String to;

  @JsonKey(name: 'value')
  String value;

  @JsonKey(name: 'data')
  String data;

  @JsonKey(name: 'payload')
  String payload;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'timestamp')
  int timestamp;

  @JsonKey(name: 'contract_address')
  String contractAddress;

  InternalTransactions(this.txHash,this.logIndex,this.from,this.to,this.value,this.data,this.payload,this.type,this.status,this.timestamp,this.contractAddress,);

  factory InternalTransactions.fromJson(Map<String, dynamic> srcJson) => _$InternalTransactionsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$InternalTransactionsToJson(this);

}

HynTransferHistory _$HynTransferHistoryFromJson(Map<String, dynamic> jsonMap) {
  return HynTransferHistory(
    jsonMap['atlas_address'] as String,
    jsonMap['block_hash'] as String,
    jsonMap['block_num'] as int,
    jsonMap['contract_address'] as String,
    jsonMap['created_at'] as int,
    jsonMap['data'] as String,
    jsonMap['data_decoded'] as Map<String, dynamic>,
    jsonMap['epoch'] as int,
    jsonMap['from'] as String,
    jsonMap['gas_limit'] as int,
    jsonMap['gas_price'] as String,
    jsonMap['gas_used'] as int,
    jsonMap['id'] as int,
    jsonMap['logs_decoded'] == null
        ? null
        : LogsDecoded.fromJson(jsonMap['logs_decoded'] as Map<String, dynamic>),
    jsonMap['map3_address'] as String,
    jsonMap['name'] as String,
    jsonMap['nonce'] as int,
    jsonMap['pic'] as String,
    jsonMap['status'] as int,
    jsonMap['timestamp'] as int,
    jsonMap['to'] as String,
    jsonMap['transaction_index'] as int,
    jsonMap['tx_hash'] as String,
    jsonMap['type'] as int,
    jsonMap['updated_at'] as int,
    jsonMap['value'] as String,
    jsonMap['payload'] == null
        ? null
        : ((jsonMap['payload'].toString() != "") ? TransferPayload.fromJson(json.decode(jsonMap['payload'])) : null),
    (jsonMap['internal_trans'] as List)
        ?.map((e) => e == null
        ? null
        : InternalTransactions.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$HynTransferHistoryToJson(HynTransferHistory instance) =>
    <String, dynamic>{
      'atlas_address': instance.atlasAddress,
      'block_hash': instance.blockHash,
      'block_num': instance.blockNum,
      'contract_address': instance.contractAddress,
      'created_at': instance.createdAt,
      'data': instance.data,
      'data_decoded': instance.dataDecoded,
      'epoch': instance.epoch,
      'from': instance.from,
      'gas_limit': instance.gasLimit,
      'gas_price': instance.gasPrice,
      'gas_used': instance.gasUsed,
      'id': instance.id,
      'logs_decoded': instance.logsDecoded,
      'map3_address': instance.map3Address,
      'name': instance.name,
      'nonce': instance.nonce,
      'pic': instance.pic,
      'status': instance.status,
      'timestamp': instance.timestamp,
      'to': instance.to,
      'transaction_index': instance.transactionIndex,
      'tx_hash': instance.txHash,
      'type': instance.type,
      'updated_at': instance.updatedAt,
      'value': instance.value,
      'payload': instance.payload,
      'internal_trans': instance.internalTransactions,
    };

DataDecoded _$DataDecodedFromJson(Map<String, dynamic> json) {
  return DataDecoded(
    json['operatorAddress'] as String,
    json['description'] == null
        ? null
        : Description.fromJson(json['description'] as Map<String, dynamic>),
    json['commission'] as String,
    json['nodePubKey'] as String,
    json['nodeKeySig'] as String,
    json['amount'] as String,
  );
}

Map<String, dynamic> _$DataDecodedToJson(DataDecoded instance) =>
    <String, dynamic>{
      'operatorAddress': instance.operatorAddress,
      'description': instance.description,
      'commission': instance.commission,
      'nodePubKey': instance.nodePubKey,
      'nodeKeySig': instance.nodeKeySig,
      'amount': instance.amount,
    };

Description _$DescriptionFromJson(Map<String, dynamic> json) {
  return Description(
    json['name'] as String,
    json['identity'] as String,
    json['website'] as String,
    json['securityContact'] as String,
    json['details'] as String,
  );
}

Map<String, dynamic> _$DescriptionToJson(Description instance) =>
    <String, dynamic>{
      'name': instance.name,
      'identity': instance.identity,
      'website': instance.website,
      'securityContact': instance.securityContact,
      'details': instance.details,
    };

LogsDecoded _$LogsDecodedFromJson(Map<String, dynamic> json) {
  return LogsDecoded(
    (json['rewards'] as List)
        ?.map((e) =>
    e == null ? null : Rewards.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['topics'] as String,
  );
}

Map<String, dynamic> _$LogsDecodedToJson(LogsDecoded instance) =>
    <String, dynamic>{
      'rewards': instance.rewards,
      'topics': instance.topics,
    };

Rewards _$RewardsFromJson(Map<String, dynamic> json) {
  return Rewards(
    json['address'] as String,
    json['amount'] as String,
  );
}

Map<String, dynamic> _$RewardsToJson(Rewards instance) => <String, dynamic>{
  'address': instance.address,
  'amount': instance.amount,
};

TransferPayload _$TransferPayloadFromJson(Map<String, dynamic> json) {
  return TransferPayload(
    json['Delegator'] as String,
    json['Map3Node'] as String,
    json['Amount'].toString(),
    json['Reward'].toString(),
  );
}

Map<String, dynamic> _$TransferPayloadToJson(TransferPayload instance) =>
    <String, dynamic>{
      'Delegator': instance.delegator,
      'Map3Node': instance.map3Node,
      'Amount': instance.amount,
      'Reward': instance.reward,
    };

InternalTransactions _$InternalTransactionsFromJson(Map<String, dynamic> json) {
  return InternalTransactions(
    json['tx_hash'] as String,
    json['log_index'] as int,
    json['from'] as String,
    json['to'] as String,
    json['value'] as String,
    json['data'] as String,
    json['payload'] as String,
    json['type'] as String,
    json['status'] as int,
    json['timestamp'] as int,
    json['contract_address'] as String,
  );
}

Map<String, dynamic> _$InternalTransactionsToJson(
    InternalTransactions instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'log_index': instance.logIndex,
      'from': instance.from,
      'to': instance.to,
      'value': instance.value,
      'data': instance.data,
      'payload': instance.payload,
      'type': instance.type,
      'status': instance.status,
      'timestamp': instance.timestamp,
      'contract_address': instance.contractAddress,
    };
