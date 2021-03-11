// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionInfoVo _$TransactionInfoVoFromJson(Map<String, dynamic> json) {
  return TransactionInfoVo(
    json['id'] as int,
    json['chain'] as String,
    json['address'] as String,
    json['hash'] as String,
    json['symbol'] as String,
    json['fromAddress'] as String,
    json['toAddress'] as String,
    json['amount'] as String,
    json['time'] as int,
    json['status'] as int,
  );
}

Map<String, dynamic> _$TransactionInfoVoToJson(TransactionInfoVo instance) => <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'chain': instance.chain,
      'hash': instance.hash,
      'symbol': instance.symbol,
      'from': instance.fromAddress,
      'to': instance.toAddress,
      'amount': instance.amount,
      'time': instance.time,
      'status': instance.status,
    };
