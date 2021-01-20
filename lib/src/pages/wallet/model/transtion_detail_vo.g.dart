// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transtion_detail_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDetailVo _$TransactionDetailVoFromJson(Map<String, dynamic> json) {
  return TransactionDetailVo(
    contractAddress: json['contractAddress'] as String,
    localTransferType: json['localTransferType'] as int,
    type: json['type'] as int,
    state: json['state'] as int,
    amount: (json['amount'] as num)?.toDouble(),
    symbol: json['symbol'] as String,
    fromAddress: json['fromAddress'] as String,
    toAddress: json['toAddress'] as String,
    time: json['time'] as int,
    hash: json['hash'] as String,
    nonce: json['nonce'] as String,
    gas: json['gas'] as String,
    gasPrice: json['gasPrice'] as String,
    gasUsed: json['gasUsed'] as String,
    describe: json['describe'] as String,
    data: json['data'] as String,
    dataDecoded: json['dataDecoded'] as Map<String, dynamic>,
    blockHash: json['blockHash'] as String,
    blockNum: json['blockNum'] as int,
    epoch: json['epoch'] as int,
    transactionIndex: json['transactionIndex'] as int,
    hynType: json['hynType'] as int,
    logsDecoded: json['logsDecoded'] == null
        ? null
        : LogsDecoded.fromJson(json['logsDecoded'] as Map<String, dynamic>),
    payload: json['payload'] == null
        ? null
        : TransferPayload.fromJson(json['payload'] as Map<String, dynamic>),
    internalTransactions: (json['internal_trans'] as List)
        ?.map((e) => e == null
            ? null
            : InternalTransactions.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    speedUpTimes: json['speedUpTimes'] as int,
    cancelTimes: json['cancelTimes'] as int,
    lastOptType: json['lastOptType'] as int,
  );
}

Map<String, dynamic> _$TransactionDetailVoToJson(
        TransactionDetailVo instance) =>
    <String, dynamic>{
      'contractAddress': instance.contractAddress,
      'type': instance.type,
      'hash': instance.hash,
      'state': instance.state,
      'amount': instance.amount,
      'symbol': instance.symbol,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'time': instance.time,
      'nonce': instance.nonce,
      'gas': instance.gas,
      'gasPrice': instance.gasPrice,
      'gasUsed': instance.gasUsed,
      'describe': instance.describe,
      'data': instance.data,
      'dataDecoded': instance.dataDecoded,
      'blockHash': instance.blockHash,
      'blockNum': instance.blockNum,
      'epoch': instance.epoch,
      'transactionIndex': instance.transactionIndex,
      'hynType': instance.hynType,
      'logsDecoded': instance.logsDecoded,
      'payload': instance.payload,
      'internal_trans': instance.internalTransactions,
      'speedUpTimes': instance.speedUpTimes,
      'cancelTimes': instance.cancelTimes,
      'lastOptType': instance.lastOptType,
      'localTransferType': instance.localTransferType,
    };
