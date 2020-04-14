// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_delegator_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractDelegatorItem _$ContractDelegatorItemFromJson(
    Map<String, dynamic> json) {
  return ContractDelegatorItem(
    json['userAddress'] as String,
    json['userName'] as String,
    json['amountDelegation'] as String,
    json['createAt'] as int,
  );
}

Map<String, dynamic> _$ContractDelegatorItemToJson(
        ContractDelegatorItem instance) =>
    <String, dynamic>{
      'userAddress': instance.userAddress,
      'userName': instance.userName,
      'amountDelegation': instance.amountDelegation,
      'createAt': instance.createAt,
    };

ContractDelegateRecordItem _$ContractDelegateRecordItemFromJson(
    Map<String, dynamic> json) {
  return ContractDelegateRecordItem(
    json['userAddress'] as String,
    json['userName'] as String,
    json['amount'] as String,
    json['txHash'] as String,
    json['operaType'] as String,
    json['createAt'] as int,
  );
}

Map<String, dynamic> _$ContractDelegateRecordItemToJson(
        ContractDelegateRecordItem instance) =>
    <String, dynamic>{
      'userAddress': instance.userAddress,
      'userName': instance.userName,
      'amount': instance.amount,
      'txHash': instance.txHash,
      'operaType': instance.operaType,
      'createAt': instance.createAt,
    };
