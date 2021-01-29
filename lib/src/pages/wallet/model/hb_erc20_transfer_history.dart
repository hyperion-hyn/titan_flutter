import 'package:json_annotation/json_annotation.dart';

part 'hb_erc20_transfer_history.g.dart';

class HbErc20TransferHistory {
  String blockNumber;
  String timeStamp;
  String hash;
  String nonce;
  String blockHash;
  String from;
  String contractAddress;
  String to;
  String value;
  String tokenName;
  String tokenSymbol;
  String tokenDecimal;
  String transactionIndex;
  String gas;
  String gasPrice;
  String gasUsed;
  String cumulativeGasUsed;
  String input;
  String confirmations;
  String txReceiptStatus;

  HbErc20TransferHistory(
      this.blockNumber,
      this.timeStamp,
      this.hash,
      this.nonce,
      this.blockHash,
      this.from,
      this.contractAddress,
      this.to,
      this.value,
      this.tokenName,
      this.tokenSymbol,
      this.tokenDecimal,
      this.transactionIndex,
      this.gas,
      this.gasPrice,
      this.gasUsed,
      this.cumulativeGasUsed,
      this.input,
      this.confirmations,
      this.txReceiptStatus,
      );

  factory HbErc20TransferHistory.fromJson(Map<String, dynamic> json) => _$HbErc20TransferHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$HbErc20TransferHistoryToJson(this);
}

HbErc20TransferHistory _$HbErc20TransferHistoryFromJson(Map<String, dynamic> json) {
  return HbErc20TransferHistory(
    json['blockNumber'].toString(),
    json['timeStamp'].toString(),
    json['hash'] as String,
    json['nonce'].toString(),
    json['blockHash'] as String,
    json['from'] as String,
    json['contractAddress'] as String,
    json['to'] as String,
    json['value'].toString(),
    json['tokenName'] as String,
    json['tokenSymbol'] as String,
    json['tokenDecimal'] as String,
    json['transactionIndex'].toString(),
    json['gas'].toString(),
    json['gasPrice'].toString(),
    json['gasUsed'].toString(),
    json['cumulativeGasUsed'].toString(),
    json['input'] as String,
    json['confirmations'].toString(),
    json['txReceiptStatus'].toString(),
  );
}

Map<String, dynamic> _$HbErc20TransferHistoryToJson(
    HbErc20TransferHistory instance) =>
    <String, dynamic>{
      'blockNumber': instance.blockNumber,
      'timeStamp': instance.timeStamp,
      'hash': instance.hash,
      'nonce': instance.nonce,
      'blockHash': instance.blockHash,
      'from': instance.from,
      'contractAddress': instance.contractAddress,
      'to': instance.to,
      'value': instance.value,
      'tokenName': instance.tokenName,
      'tokenSymbol': instance.tokenSymbol,
      'tokenDecimal': instance.tokenDecimal,
      'transactionIndex': instance.transactionIndex,
      'gas': instance.gas,
      'gasPrice': instance.gasPrice,
      'gasUsed': instance.gasUsed,
      'cumulativeGasUsed': instance.cumulativeGasUsed,
      'input': instance.input,
      'confirmations': instance.confirmations,
      'txReceiptStatus': instance.txReceiptStatus,
    };