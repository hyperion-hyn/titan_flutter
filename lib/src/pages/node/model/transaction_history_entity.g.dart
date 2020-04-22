// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_history_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionHistoryEntity _$TransactionHistoryEntityFromJson(
    Map<String, dynamic> json) {
  return TransactionHistoryEntity(
    json['userAddress'] as String,
    json['instanceId'] as int,
    json['txhash'] as String,
    json['operaType'] as String,
    json['amount'] as int,
    json['shareKey'] as String,
  );
}

Map<String, dynamic> _$TransactionHistoryEntityToJson(
        TransactionHistoryEntity instance) =>
    <String, dynamic>{
      'userAddress': instance.userAddress,
      'instanceId': instance.instanceId,
      'txhash': instance.txhash,
      'operaType': instance.operaType,
      'amount': instance.amount,
      'shareKey': instance.shareKey,
    };
