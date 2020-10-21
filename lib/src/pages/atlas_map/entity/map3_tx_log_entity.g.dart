// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map3_tx_log_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map3TxLogEntity _$Map3TxLogEntityFromJson(Map<String, dynamic> json) {
  return Map3TxLogEntity(
    json['atlas_address'] as String,
    json['block_hash'] as String,
    json['block_num'] as int,
    json['contract_address'] as String,
    json['created_at'] as String,
    json['data'] as String,
    json['dataDecoded'] == null
        ? null
        : DataDecoded.fromJson(json['dataDecoded'] as Map<String, dynamic>),
    json['epoch'] as int,
    json['from'] as String,
    json['gas_limit'] as int,
    json['gas_price'] as String,
    json['gas_used'] as int,
    json['handle_status'] as int,
    json['id'] as int,
    json['map3_address'] as String,
    json['name'] as String,
    json['nonce'] as int,
    json['payload'] as String,
    json['pic'] as String,
    json['status'] as int,
    json['timestamp'] as int,
    json['to'] as String,
    json['transaction_index'] as int,
    json['tx_hash'] as String,
    json['type'] as int,
    json['updated_at'] as String,
    json['value'] as String,
  );
}

Map<String, dynamic> _$Map3TxLogEntityToJson(Map3TxLogEntity instance) =>
    <String, dynamic>{
      'atlas_address': instance.atlasAddress,
      'block_hash': instance.blockHash,
      'block_num': instance.blockNum,
      'contract_address': instance.contractAddress,
      'created_at': instance.createdAt,
      'data': instance.data,
      'dataDecoded': instance.dataDecoded,
      'epoch': instance.epoch,
      'from': instance.from,
      'gas_limit': instance.gasLimit,
      'gas_price': instance.gasPrice,
      'gas_used': instance.gasUsed,
      'handle_status': instance.handleStatus,
      'id': instance.id,
      'map3_address': instance.map3Address,
      'name': instance.name,
      'nonce': instance.nonce,
      'payload': instance.payload,
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