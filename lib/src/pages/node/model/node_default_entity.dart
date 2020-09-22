import 'package:json_annotation/json_annotation.dart';

part 'node_default_entity.g.dart';


@JsonSerializable()
class NodeDefaultEntity extends Object {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'amount')
  double amount;

  @JsonKey(name: 'publicKey')
  String publicKey;

  @JsonKey(name: 'txHash')
  String txHash;

  @JsonKey(name: 'nodeProvider')
  String nodeProvider;

  @JsonKey(name: 'nodeRegion')
  String nodeRegion;

  @JsonKey(name: 'shareKey')
  String shareKey;

  @JsonKey(name: 'gasprice')
  int gasPrice;

  NodeDefaultEntity(this.address,this.txHash,this.gasPrice,{this.name,this.amount,this.publicKey,this.nodeProvider,this.nodeRegion,this.shareKey});

  factory NodeDefaultEntity.fromJson(Map<String, dynamic> srcJson) => _$NodeDefaultEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeDefaultEntityToJson(this);

}