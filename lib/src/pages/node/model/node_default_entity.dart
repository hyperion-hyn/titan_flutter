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

  NodeDefaultEntity(this.address,this.txHash,{this.name,this.amount,this.publicKey,this.nodeProvider,this.nodeRegion,});

  factory NodeDefaultEntity.fromJson(Map<String, dynamic> srcJson) => _$NodeDefaultEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeDefaultEntityToJson(this);

}