import 'package:json_annotation/json_annotation.dart'; 
  
part 'contract_delegator_item.g.dart';


@JsonSerializable()
  class ContractDelegatorItem extends Object {

  @JsonKey(name: 'userAddress')
  String userAddress;

  @JsonKey(name: 'userName')
  String userName;

  @JsonKey(name: 'amountDelegation')
  String amountDelegation;

  @JsonKey(name: 'createAt')
  int createAt;

  ContractDelegatorItem(this.userAddress, this.userName,this.amountDelegation,this.createAt,);

  factory ContractDelegatorItem.fromJson(Map<String, dynamic> srcJson) => _$ContractDelegatorItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractDelegatorItemToJson(this);

}

@JsonSerializable()
class ContractDelegateRecordItem extends Object {

  @JsonKey(name: 'userAddress')
  String userAddress;

  @JsonKey(name: 'userName')
  String userName;

  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'txHash')
  String txHash;

  @JsonKey(name: 'operaType')
  String operaType;

  @JsonKey(name: 'createAt')
  int createAt;

  @JsonKey(name: 'state')
  String state;

  ContractDelegateRecordItem(this.userAddress, this.userName,this.amount, this.txHash, this.operaType,this.createAt, this.state);

  factory ContractDelegateRecordItem.fromJson(Map<String, dynamic> srcJson) => _$ContractDelegateRecordItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractDelegateRecordItemToJson(this);

}
