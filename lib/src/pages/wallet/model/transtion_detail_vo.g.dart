// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transtion_detail_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDetailVo _$TransactionDetailVoFromJson(Map<String, dynamic> json) {
  return TransactionDetailVo(
    id: json['id'] as int,
    type: json['type'] as int,
    state: json['state'] as int,
    amount: double.parse(json['amount']),
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
    contractAddress: json['contractAddress'] as String,
    localTransferType: json['localTransferType'] as int,
    password: json['password'] as String,
  );
}

Map<String, dynamic> _$TransactionDetailVoToJson(
        TransactionDetailVo instance) =>
    <String, dynamic>{
      'id': instance.id,
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
      'contractAddress': instance.contractAddress,
      'localTransferType': instance.localTransferType,
      'password': instance.password,
    };
