// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_info_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalInfoLog _$WithdrawalInfoLogFromJson(Map<String, dynamic> json) {
  return WithdrawalInfoLog(
    json['id'] as int,
    (json['amount'] as num)?.toDouble(),
    (json['fee'] as num)?.toDouble(),
    json['created_at'] as int,
    json['state'] as String,
    json['state_title'] as String,
  );
}

Map<String, dynamic> _$WithdrawalInfoLogToJson(WithdrawalInfoLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'fee': instance.fee,
      'created_at': instance.createAt,
      'state': instance.state,
      'state_title': instance.stateTitle,
    };
