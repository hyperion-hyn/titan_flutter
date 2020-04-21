// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_transaction_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractTransactionEntity _$ContractTransactionEntityFromJson(
    Map<String, dynamic> json) {
  return ContractTransactionEntity(
    json['address'] as String,
    json['name'] as String,
    json['amount'] as int,
    json['publicKey'] as String,
    json['txHash'] as String,
  );
}

Map<String, dynamic> _$ContractTransactionEntityToJson(
        ContractTransactionEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'amount': instance.amount,
      'publicKey': instance.publicKey,
      'txHash': instance.txHash,
    };
