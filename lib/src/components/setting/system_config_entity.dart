import 'package:json_annotation/json_annotation.dart';

part 'system_config_entity.g.dart';


@JsonSerializable()
class SystemConfigEntity extends Object {

  @JsonKey(name: 'ethTransferGasLimit')
  int ethTransferGasLimit = 21000;

  @JsonKey(name: 'erc20TransferGasLimit')
  int erc20TransferGasLimit = 55000;

  @JsonKey(name: 'erc20ApproveGasLimit')
  int erc20ApproveGasLimit = 50000;

  @JsonKey(name: 'createMap3NodeGasLimit')
  int createMap3NodeGasLimit = 560000;

  @JsonKey(name: 'delegateMap3NodeGasLimit')
  int delegateMap3NodeGasLimit = 700000;

  @JsonKey(name: 'collectMap3NodeCreatorGasLimit')
  int collectMap3NodeCreatorGasLimit = 2800000;

  @JsonKey(name: 'collectMap3NodePartnerGasLimit')
  int collectMap3NodePartnerGasLimit = 80000;

  @JsonKey(name: 'collectHalfMap3NodeGasLimit')
  int collectHalfMap3NodeGasLimit = 150000;

  SystemConfigEntity(this.ethTransferGasLimit,this.erc20TransferGasLimit,this.erc20ApproveGasLimit,this.createMap3NodeGasLimit,this.delegateMap3NodeGasLimit,this.collectMap3NodeCreatorGasLimit,this.collectMap3NodePartnerGasLimit,this.collectHalfMap3NodeGasLimit,);

  factory SystemConfigEntity.fromJson(Map<String, dynamic> srcJson) => _$SystemConfigEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SystemConfigEntityToJson(this);

}