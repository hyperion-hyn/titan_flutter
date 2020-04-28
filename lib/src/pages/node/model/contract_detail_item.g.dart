// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_detail_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractDetailItem _$ContractDetailItemFromJson(Map<String, dynamic> json) {
  return ContractDetailItem(
    json['instance'] == null
        ? null
        : ContractNodeItem.fromJson(json['instance'] as Map<String, dynamic>),
    json['userAddress'] as String,
    json['ownerAddress'] as String,
    json['amountDelegation'] as String,
    json['amountPreDelegation'] as String,
    json['expectedYield'] as String,
    json['commission'] as String,
    json['delegatorCount'] as int,
    json['withdrawn'] as String,
    json['preWithdrawn'] as String,
    json['isOwner'] as bool,
    json['lastRecord'] == null
        ? null
        : ContractDelegateRecordItem.fromJson(
            json['lastRecord'] as Map<String, dynamic>),
    json['state'] as String,
  );
}


Map<String, dynamic> _$ContractDetailItemToJson(ContractDetailItem instance) =>
    <String, dynamic>{
      'instance': instance.instance,
      'userAddress': instance.userAddress,
      'ownerAddress': instance.ownerAddress,
      'amountDelegation': instance.amountDelegation,
      'amountPreDelegation': instance.amountPreDelegation,
      'expectedYield': instance.expectedYield,
      'commission': instance.commission,
      'delegatorCount': instance.delegatorCount,
      'withdrawn': instance.withdrawn,
      'preWithdrawn': instance.preWithdrawn,
      'isOwner': instance.isOwner,
      'lastRecord': instance.lastRecord,
      'state': instance.state,
    };

