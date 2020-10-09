// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hyn_transfer_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HynTransferHistory _$HynTransferHistoryFromJson(Map<String, dynamic> json) {
  return HynTransferHistory(
    json['id'] as int,
    json['createdAt'] as int,
    json['updatedAt'] as int,
    json['tx_hash'] as String,
    json['from'] as String,
    json['to'] as String,
    json['nonce'] as int,
    json['value'] as String,
    json['data'] as String,
    json['gas_price'] as String,
    json['gas_limit'] as int,
    json['type'] as int,
    json['status'] as int,
    json['gas_used'] as int,
    json['block_hash'] as String,
    json['block_num'] as int,
    json['epoch'] as int,
    json['timestamp'] as int,
    json['contract_address'] as String,
    json['transaction_index'] as int,
    json['hynUsdPrice'] as int,
    json['hynCnyPrice'] as int,
  );
}

Map<String, dynamic> _$HynTransferHistoryToJson(HynTransferHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'tx_hash': instance.txHash,
      'from': instance.from,
      'to': instance.to,
      'nonce': instance.nonce,
      'value': instance.value,
      'data': instance.data,
      'gas_price': instance.gasPrice,
      'gas_limit': instance.gasLimit,
      'type': instance.type,
      'status': instance.status,
      'gas_used': instance.gasUsed,
      'block_hash': instance.blockHash,
      'block_num': instance.blockNum,
      'epoch': instance.epoch,
      'timestamp': instance.timestamp,
      'contract_address': instance.contractAddress,
      'transaction_index': instance.transactionIndex,
      'hynUsdPrice': instance.hynUsdPrice,
      'hynCnyPrice': instance.hynCnyPrice,
    };
