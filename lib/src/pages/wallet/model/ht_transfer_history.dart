import 'package:json_annotation/json_annotation.dart';

class HtTransferHistory {
  String blockNumber;
  String timeStamp;
  String hash;
  String nonce;
  String blockHash;
  String transactionIndex;
  String from;
  String to;
  String value;
  String gas;
  String gasPrice;
  String isError;
  String txReceiptStatus;
  String input;
  String contractAddress;
  String cumulativeGasUsed;
  String gasUsed;
  String confirmations;

  HtTransferHistory(
      this.blockNumber,
      this.timeStamp,
      this.hash,
      this.nonce,
      this.blockHash,
      this.transactionIndex,
      this.from,
      this.to,
      this.value,
      this.gas,
      this.gasPrice,
      this.isError,
      this.txReceiptStatus,
      this.input,
      this.contractAddress,
      this.cumulativeGasUsed,
      this.gasUsed,
      this.confirmations);

  factory HtTransferHistory.fromJson(Map<String, dynamic> json) => _$HtTransferHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$HtTransferHistoryToJson(this);
}

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