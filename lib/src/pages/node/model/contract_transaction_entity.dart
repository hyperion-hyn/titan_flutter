import 'package:json_annotation/json_annotation.dart'; 
  
part 'contract_transaction_entity.g.dart';


@JsonSerializable()
  class ContractTransactionEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'amount')
  int amount;

  @JsonKey(name: 'publicKey')
  String publicKey;

  @JsonKey(name: 'txHash')
  String txHash;

  ContractTransactionEntity(this.address,this.name,this.amount,this.publicKey,this.txHash,);

  factory ContractTransactionEntity.fromJson(Map<String, dynamic> srcJson) => _$ContractTransactionEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContractTransactionEntityToJson(this);

}

  
