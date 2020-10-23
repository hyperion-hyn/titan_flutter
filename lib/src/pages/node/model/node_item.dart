import 'package:json_annotation/json_annotation.dart'; 
  
part 'node_item.g.dart';


@JsonSerializable()
  class NodeItem extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'nodeName')
  String nodeName;

  @JsonKey(name: 'nodeId')
  int nodeId;

  @JsonKey(name: 'minTotalDelegation')
  String minTotalDelegation;

  @JsonKey(name: 'ownerMinDelegationRate')
  double ownerMinDelegationRate;

  @JsonKey(name: 'minDelegationRate')
  double minDelegationRate;

  @JsonKey(name: 'annualizedYield')
  double annualizedYield;

  @JsonKey(name: 'duration')
  int duration;

  @JsonKey(name: 'durationType')
  int durationType;

  @JsonKey(name: 'commission')
  double commission;

  @JsonKey(name: 'halfCollected')
  bool halfCollected;

  @JsonKey(name: 'halfCollectedDuration')
  String halfCollectedDuration;

  @JsonKey(name: 'halfCollectedRate')
  String halfCollectedRate;

  @JsonKey(name: 'suggestQuantity')
  String suggestQuantity;

  NodeItem(this.id,this.nodeName,this.nodeId,this.minTotalDelegation,this.ownerMinDelegationRate,this.minDelegationRate,this.annualizedYield,this.duration,this.durationType,this.commission,this.halfCollected,this.halfCollectedDuration,this.halfCollectedRate,this.suggestQuantity,);

  factory NodeItem.fromJson(Map<String, dynamic> srcJson) => _$NodeItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeItemToJson(this);

  get name {
    return "${this.nodeName??"Map3云节点（V1.0）"}";
  }

}

  
