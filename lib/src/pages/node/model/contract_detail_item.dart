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

  @JsonKey(name: 'state')
  String state;

  ContractDetailItem(this.instance,this.userAddress,this.ownerAddress,this.amountDelegation,this.expectedYield,this.commission,this.delegatorCount,this.state,);

  factory ContractDetailItem.fromJson(Map<String, dynamic> srcJson) => _$ContractDetailItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractDetailItemToJson(this);

}

