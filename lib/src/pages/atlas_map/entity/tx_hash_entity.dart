import 'package:json_annotation/json_annotation.dart'; 
  
part 'tx_hash_entity.g.dart';


@JsonSerializable()
  class TxHashEntity extends Object {

  @JsonKey(name: 'tx_hash')
  String txHash;

  @JsonKey(name: 'node_id')
  String nodeId;

  TxHashEntity(this.txHash, this.nodeId);

  factory TxHashEntity.fromJson(Map<String, dynamic> srcJson) => _$TxHashEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TxHashEntityToJson(this);

}

  
