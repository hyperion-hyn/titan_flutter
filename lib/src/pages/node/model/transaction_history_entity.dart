import 'package:json_annotation/json_annotation.dart'; 
  
part 'transaction_history_entity.g.dart';


@JsonSerializable()
  class TransactionHistoryEntity extends Object {

  @JsonKey(name: 'userAddress')
  String userAddress;

  @JsonKey(name: 'instanceId')
  int instanceId;

  @JsonKey(name: 'txhash')
  String txhash;

  @JsonKey(name: 'operaType')
  String operaType;

  TransactionHistoryEntity(this.userAddress,this.instanceId,this.txhash,this.operaType,);

  factory TransactionHistoryEntity.fromJson(Map<String, dynamic> srcJson) => _$TransactionHistoryEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TransactionHistoryEntityToJson(this);

}

  
