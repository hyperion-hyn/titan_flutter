import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
  
part 'contract_node_item.g.dart';


@JsonSerializable()
  class ContractNodeItem extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'contract')
  NodeItem contract;

  @JsonKey(name: 'owner')
  String owner;

  @JsonKey(name: 'amountDelegation')
  int amountDelegation;

  @JsonKey(name: 'remainDelegation')
  int remainDelegation;

  @JsonKey(name: 'instanceStartTime')
  String instanceStartTime;

  @JsonKey(name: 'state')
  String state;

  ContractNodeItem(this.id,this.contract,this.owner,this.amountDelegation,this.remainDelegation,this.instanceStartTime,this.state,);

  factory ContractNodeItem.fromJson(Map<String, dynamic> srcJson) => _$ContractNodeItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractNodeItemToJson(this);

}


