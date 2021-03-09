// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionInfoVo _$TransactionInfoVoFromJson(Map<String, dynamic> json) {
  return TransactionInfoVo(
    json['id'] as int,
    json['chain'] as String,
    json['hash'] as String,
    json['symbol'] as String,
    json['from'] as String,
    json['to'] as String,
    json['amount'] as int,
    json['time'] as int,
    json['status'] as int,
  );
}

Map<String, dynamic> _$TransactionInfoVoToJson(TransactionInfoVo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hash': instance.hash,
      'symbol': instance.symbol,
      'from': instance.from,
      'to': instance.to,
      'amount': instance.amount,
      'time': instance.time,
      'status': instance.status,
    };
