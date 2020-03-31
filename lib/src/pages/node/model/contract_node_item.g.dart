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
    json['amountDelegation'] as int,
    json['remainDelegation'] as int,
    json['instanceStartTime'] as int,
    json['state'] as String,
  );
}

Map<String, dynamic> _$ContractNodeItemToJson(ContractNodeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contract': instance.contract,
      'owner': instance.owner,
      'ownerName': instance.ownerName,
      'amountDelegation': instance.amountDelegation,
      'remainDelegation': instance.remainDelegation,
      'instanceStartTime': instance.instanceStartTime,
      'state': instance.state,
    };
