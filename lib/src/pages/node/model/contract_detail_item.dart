import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
  
part 'contract_detail_item.g.dart';


@JsonSerializable()
  class ContractDetailItem extends Object {

  @JsonKey(name: 'instance')
  ContractNodeItem instance;

  @JsonKey(name: 'userAddress')
  String userAddress;

  @JsonKey(name: 'ownerAddress')
  String ownerAddress;

  @JsonKey(name: 'amountDelegation')
  String amountDelegation;

  @JsonKey(name: 'expectedYield')
  String expectedYield;

  @JsonKey(name: 'commission')
  String commission;

  @JsonKey(name: 'delegatorCount')
  int delegatorCount;


  @JsonKey(name: 'latestTransaction')
  LatestTransaction latestTransaction;

  @JsonKey(name: 'state')
  String state;

  ContractDetailItem(this.instance,this.userAddress,this.ownerAddress,this.amountDelegation,this.expectedYield,this.commission,this.delegatorCount, this.latestTransaction,this.state,);

  factory ContractDetailItem.fromJson(Map<String, dynamic> srcJson) => _$ContractDetailItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractDetailItemToJson(this);

}


@JsonSerializable()
class LatestTransaction extends Object {

  @JsonKey(name: 'userAddress')
  String userAddress;

  @JsonKey(name: 'instanceId')
  int instanceId;

  @JsonKey(name: 'delegationId')
  int delegationId;

  @JsonKey(name: 'txhash')
  String txhash;

  @JsonKey(name: 'operaType')
  String operaType;

  @JsonKey(name: 'state')
  String state;

  LatestTransaction(this.userAddress,this.instanceId,this.delegationId,this.txhash,this.operaType,this.state,);

  factory LatestTransaction.fromJson(Map<String, dynamic> srcJson) => _$LatestTransactionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LatestTransactionToJson(this);

}