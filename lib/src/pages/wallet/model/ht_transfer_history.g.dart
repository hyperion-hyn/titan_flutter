// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ht_transfer_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HtTransferHistory _$HtTransferHistoryFromJson(Map<String, dynamic> json) {
  return HtTransferHistory(
    json['blockNumber'].toString(),
    json['timeStamp'].toString(),
    json['hash'] as String,
    json['nonce'].toString(),
    json['blockHash'] as String,
    json['transactionIndex'].toString(),
    json['from'] as String,
    json['to'] as String,
    json['value'].toString(),
    json['gas'].toString(),
    json['gasPrice'].toString(),
    json['isError'] as String,
    json['txReceiptStatus'].toString(),
    json['input'] as String,
    json['contractAddress'] as String,
    json['cumulativeGasUsed'].toString(),
    json['gasUsed'].toString(),
    json['confirmations'].toString(),
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
