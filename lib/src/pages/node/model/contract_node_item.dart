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

  @JsonKey(name: 'nodeProvider')
  String nodeProvider;

  @JsonKey(name: 'nodeProviderName')
  String nodeProviderName;

  @JsonKey(name: 'nodeRegion')
  String nodeRegion;

  @JsonKey(name: 'nodeRegionName')
  String nodeRegionName;

  @JsonKey(name: 'expectDueTime')
  int expectDueTime;

  @JsonKey(name: 'expectCancelTime')
  int expectCancelTime;

  @JsonKey(name: 'instanceStartTime')
  int instanceStartTime;

  @JsonKey(name: 'instanceActiveTime')
  int instanceActiveTime;

  @JsonKey(name: 'instanceDueTime')
  int instanceDueTime;

  @JsonKey(name: 'instanceCancelTime')
  int instanceCancelTime;

  @JsonKey(name: 'instanceFinishTime')
  int instanceFinishTime;

  @JsonKey(name: 'state')
  String state;

  ContractNodeItem(
      this.id,
      this.contract,
      this.owner,
      this.ownerName,
      this.amountDelegation,
      this.remainDelegation,
      this.nodeProvider,
      this.nodeRegion,
      this.nodeRegionName,
      this.expectDueTime,
      this.expectCancelTime,
      this.instanceStartTime,
      this.instanceActiveTime,
      this.instanceDueTime,
      this.instanceCancelTime,
      this.instanceFinishTime,
      this.state
      );

  ContractNodeItem.onlyNodeItem(this.contract);

  ContractNodeItem.onlyNodeId(this.id);

  factory ContractNodeItem.fromJson(Map<String, dynamic> srcJson) => _$ContractNodeItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractNodeItemToJson(this);

  // todo: test_jison_0411
  String get remainDay{
    //return "0";
    double remian = (expectCancelTime - instanceStartTime) / 3600 / 24;
    return FormatUtil.doubleFormatNum(remian);
  }

}


