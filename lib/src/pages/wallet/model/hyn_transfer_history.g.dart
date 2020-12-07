// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hyn_transfer_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HynTransferHistory _$HynTransferHistoryFromJson(Map<String, dynamic> jsonMap) {
  return HynTransferHistory(
    jsonMap['atlas_address'] as String,
    jsonMap['block_hash'] as String,
    jsonMap['block_num'] as int,
    jsonMap['contract_address'] as String,
    jsonMap['created_at'] as int,
    jsonMap['data'] as String,
    jsonMap['data_decoded'] == null
        ? null
        : jsonMap['data_decoded'] as Map<String, dynamic>,
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
    (jsonMap['payload'] == null || (jsonMap['payload'] as String).isEmpty ) ? null
        : TransferPayload.fromJson(json.decode(jsonMap['payload'])),
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
    json['Amount']?.toString() ?? "",
    json['Reward']?.toString() ?? "",
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