// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ht_transfer_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HtTransferHistory _$HtTransferHistoryFromJson(Map<String, dynamic> json) {
  return HtTransferHistory(
    json['blockNumber'] as String,
    json['timeStamp'] as String,
    json['hash'] as String,
    json['nonce'] as String,
    json['blockHash'] as String,
    json['transactionIndex'] as String,
    json['from'] as String,
    json['to'] as String,
    json['value'] as String,
    json['gas'] as String,
    json['gasPrice'] as String,
    json['isError'] as String,
    json['txReceiptStatus'] as String,
    json['input'] as String,
    json['contractAddress'] as String,
    json['cumulativeGasUsed'] as String,
    json['gasUsed'] as String,
    json['confirmations'] as String,
  );
}

Map<String, dynamic> _$HtTransferHistoryToJson(HtTransferHistory instance) =>
    <String, dynamic>{
      'blockNumber': instance.blockNumber,
      'timeStamp': instance.timeStamp,
      'hash': instance.hash,
      'nonce': instance.nonce,
      'blockHash': instance.blockHash,
      'transactionIndex': instance.transactionIndex,
      'from': instance.from,
      'to': instance.to,
      'value': instance.value,
      'gas': instance.gas,
      'gasPrice': instance.gasPrice,
      'isError': instance.isError,
      'txReceiptStatus': instance.txReceiptStatus,
      'input': instance.input,
      'contractAddress': instance.contractAddress,
      'cumulativeGasUsed': instance.cumulativeGasUsed,
      'gasUsed': instance.gasUsed,
      'confirmations': instance.confirmations,
    };
