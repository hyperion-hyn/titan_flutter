import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';

import 'contract_delegator_item.dart';

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

  @JsonKey(name: 'amountPreDelegation')
  String amountPreDelegation;

  @JsonKey(name: 'expectedYield')
  String expectedYield;

  @JsonKey(name: 'commission')
  String commission;

  @JsonKey(name: 'delegatorCount')
  int delegatorCount;

  @JsonKey(name: 'withdrawn')
  String withdrawn;

  @JsonKey(name: 'preWithdrawn')
  String preWithdrawn;

  @JsonKey(name: 'isOwner')
  bool isOwner;

  @JsonKey(name: 'lastRecord')
  ContractDelegateRecordItem lastRecord;

//  enum UserDelegateState { PRE_CREATE, PENDING, CANCELLED, PRE_CANCELLED_COLLECTED, CANCELLED_COLLECTED , ACTIVE, HALFDUE, PRE_HALFDUE_COLLECTED, HALFDUE_COLLECTED, DUE, PRE_DUE_COLLECTED, DUE_COLLECTED,FAIL}
  @JsonKey(name: 'state')
  String state;

  ContractDetailItem(
    this.instance,
    this.userAddress,
    this.ownerAddress,
    this.amountDelegation,
    this.amountPreDelegation,
    this.expectedYield,
    this.commission,
    this.delegatorCount,
    this.withdrawn,
    this.preWithdrawn,
    this.isOwner,
    this.lastRecord,
    this.state,
  );

  factory ContractDetailItem.fromJson(Map<String, dynamic> srcJson) => _$ContractDetailItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractDetailItemToJson(this);
}
