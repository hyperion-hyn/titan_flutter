// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hyn_transfer_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HynTransferHistory _$HynTransferHistoryFromJson(Map<String, dynamic> json) {
  return HynTransferHistory(
    json['atlas_address'] as String,
    json['block_hash'] as String,
    json['block_num'] as int,
    json['contract_address'] as String,
    json['created_at'] as int,
    json['data'] as String,
    json['data_decoded'] == null
        ? null
        : DataDecoded.fromJson(json['data_decoded'] as Map<String, dynamic>),
    json['epoch'] as int,
    json['from'] as String,
    json['gas_limit'] as int,
    json['gas_price'] as String,
    json['gas_used'] as int,
    json['id'] as int,
    json['logs_decoded'] == null
        ? null
        : LogsDecoded.fromJson(json['logs_decoded'] as Map<String, dynamic>),
    json['map3_address'] as String,
    json['name'] as String,
    json['nonce'] as int,
    json['pic'] as String,
    json['status'] as int,
    json['timestamp'] as int,
    json['to'] as String,
    json['transaction_index'] as int,
    json['tx_hash'] as String,
    json['type'] as int,
    json['updated_at'] as int,
    json['value'] as String,
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
