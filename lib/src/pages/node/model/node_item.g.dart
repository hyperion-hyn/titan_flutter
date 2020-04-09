// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeItem _$NodeItemFromJson(Map<String, dynamic> json) {
  return NodeItem(
    json['id'] as int,
    json['nodeName'] as String,
    json['nodeId'] as int,
    json['minTotalDelegation'] as int,
    (json['ownerMinDelegationRate'] as num)?.toDouble(),
    (json['minDelegationRate'] as num)?.toDouble(),
    (json['annualizedYield'] as num)?.toDouble(),
    json['duration'] as int,
    json['durationType'] as int,
    (json['commission'] as num)?.toDouble(),
    json['halfCollected'] as bool,
    json['halfCollectedDuration'] as String,
    json['halfCollectedRate'] as String,
    json['suggestQuantity'] as String,
  );
}

Map<String, dynamic> _$NodeItemToJson(NodeItem instance) => <String, dynamic>{
      'id': instance.id,
      'nodeName': instance.nodeName,
      'nodeId': instance.nodeId,
      'minTotalDelegation': instance.minTotalDelegation,
      'ownerMinDelegationRate': instance.ownerMinDelegationRate,
      'minDelegationRate': instance.minDelegationRate,
      'annualizedYield': instance.annualizedYield,
      'duration': instance.duration,
      'durationType': instance.durationType,
      'commission': instance.commission,
      'halfCollected': instance.halfCollected,
      'halfCollectedDuration': instance.halfCollectedDuration,
      'halfCollectedRate': instance.halfCollectedRate,
      'suggestQuantity': instance.suggestQuantity,
    };
