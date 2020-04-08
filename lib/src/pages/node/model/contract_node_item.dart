import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/utils/format_util.dart';
  
part 'contract_node_item.g.dart';


@JsonSerializable()
  class ContractNodeItem extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'contract')
  NodeItem contract;

  @JsonKey(name: 'owner')
  String owner;

  @JsonKey(name: 'ownerName')
  String ownerName;

  @JsonKey(name: 'amountDelegation')
  String amountDelegation;

  @JsonKey(name: 'remainDelegation')
  String remainDelegation;

  @JsonKey(name: 'expectCancelTime')
  int expectCancelTime;

  @JsonKey(name: 'instanceStartTime')
  int instanceStartTime;

  @JsonKey(name: 'state')
  String state;

  ContractNodeItem(this.id,this.contract,this.owner,this.ownerName,this.amountDelegation,this.remainDelegation,this.expectCancelTime, this.instanceStartTime,this.state,);

  ContractNodeItem.onlyNodeItem(this.contract);

  ContractNodeItem.onlyNodeId(this.id);

  factory ContractNodeItem.fromJson(Map<String, dynamic> srcJson) => _$ContractNodeItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractNodeItemToJson(this);

  String get remainDay{
    double remian = (expectCancelTime - instanceStartTime) / 3600 / 24;
    return FormatUtil.doubleFormatNum(remian);
  }

}


