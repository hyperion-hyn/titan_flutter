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
    json['amountDelegation'] as int,
    json['expectedYield'] as int,
    json['commission'] as int,
    json['delegatorCount'] as int,
    json['state'] as String,
  );
}

Map<String, dynamic> _$ContractDetailItemToJson(ContractDetailItem instance) =>
    <String, dynamic>{
      'instance': instance.instance,
      'userAddress': instance.userAddress,
      'ownerAddress': instance.ownerAddress,
      'amountDelegation': instance.amountDelegation,
      'expectedYield': instance.expectedYield,
      'commission': instance.commission,
      'delegatorCount': instance.delegatorCount,
      'state': instance.state,
    };
