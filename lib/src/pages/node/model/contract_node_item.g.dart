// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_node_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractNodeItem _$ContractNodeItemFromJson(Map<String, dynamic> json) {
  return ContractNodeItem(
    json['id'] as int,
    json['contract'] == null
        ? null
        : NodeItem.fromJson(json['contract'] as Map<String, dynamic>),
    json['owner'] as String,
    json['ownerName'] as String,
    json['amountDelegation'] as String,
    json['remainDelegation'] as String,
    json['nodeProvider'] as String,
    json['nodeRegion'] as String,
    json['nodeRegionName'] as String,
    json['expectDueTime'] as int,
    json['expectCancelTime'] as int,
    json['instanceStartTime'] as int,
    json['instanceActiveTime'] as int,
    json['instanceDueTime'] as int,
    json['instanceCancelTime'] as int,
    json['instanceFinishTime'] as int,
    json['state'] as String,
  )..nodeProviderName = json['nodeProviderName'] as String;
}

Map<String, dynamic> _$ContractNodeItemToJson(ContractNodeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contract': instance.contract,
      'owner': instance.owner,
      'ownerName': instance.ownerName,
      'amountDelegation': instance.amountDelegation,
      'remainDelegation': instance.remainDelegation,
      'nodeProvider': instance.nodeProvider,
      'nodeProviderName': instance.nodeProviderName,
      'nodeRegion': instance.nodeRegion,
      'nodeRegionName': instance.nodeRegionName,
      'expectDueTime': instance.expectDueTime,
      'expectCancelTime': instance.expectCancelTime,
      'instanceStartTime': instance.instanceStartTime,
      'instanceActiveTime': instance.instanceActiveTime,
      'instanceDueTime': instance.instanceDueTime,
      'instanceCancelTime': instance.instanceCancelTime,
      'instanceFinishTime': instance.instanceFinishTime,
      'state': instance.state,
    };
