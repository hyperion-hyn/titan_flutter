// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hb_erc20_transfer_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
