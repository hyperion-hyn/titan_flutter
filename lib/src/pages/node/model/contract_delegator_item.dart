import 'package:json_annotation/json_annotation.dart'; 
  
part 'contract_delegator_item.g.dart';


@JsonSerializable()
  class ContractDelegatorItem extends Object {

  @JsonKey(name: 'userAddress')
  String userAddress;

  @JsonKey(name: 'userName')
  String userName;

  @JsonKey(name: 'amountDelegation')
  int amountDelegation;

  @JsonKey(name: 'createAt')
  int createAt;

  ContractDelegatorItem(this.userAddress, this.userName,this.amountDelegation,this.createAt,);

  factory ContractDelegatorItem.fromJson(Map<String, dynamic> srcJson) => _$ContractDelegatorItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractDelegatorItemToJson(this);

}

  
