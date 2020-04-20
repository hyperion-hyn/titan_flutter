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
    json['latestTransaction'] == null
        ? null
        : LatestTransaction.fromJson(
            json['latestTransaction'] as Map<String, dynamic>),
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
      'latestTransaction': instance.latestTransaction,
      'state': instance.state,
    };


LatestTransaction _$LatestTransactionFromJson(Map<String, dynamic> json) {
  return LatestTransaction(
    json['userAddress'] as String,
    json['instanceId'] as int,
    json['delegationId'] as int,
    json['amount'] as String,
    json['shareKey'] as String,
    json['txhash'] as String,
    json['operaType'] as String,
    json['state'] as String,
  );
}

Map<String, dynamic> _$LatestTransactionToJson(LatestTransaction instance) =>
    <String, dynamic>{
      'userAddress': instance.userAddress,
      'instanceId': instance.instanceId,
      'amount': instance.amount,
      'shareKey': instance.shareKey,
      'delegationId': instance.delegationId,
      'txhash': instance.txhash,
      'operaType': instance.operaType,
      'state': instance.state,
    };
