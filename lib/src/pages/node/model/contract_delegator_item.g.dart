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
    json['amountDelegation'] as int,
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
