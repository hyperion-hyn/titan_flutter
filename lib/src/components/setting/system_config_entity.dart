import 'package:json_annotation/json_annotation.dart';

part 'system_config_entity.g.dart';

@JsonSerializable()
class SystemConfigEntity extends Object {
  @JsonKey(name: 'ethTransferGasLimit')
  int ethTransferGasLimit = 21000;

  @JsonKey(name: 'erc20TransferGasLimit')
  int erc20TransferGasLimit = 65000;

  @JsonKey(name: 'erc20ApproveGasLimit')
  int erc20ApproveGasLimit = 50000;

  @JsonKey(name: 'createMap3NodeGasLimit')
  int createMap3NodeGasLimit = 560000;

  @JsonKey(name: 'delegateMap3NodeGasLimit')
  int delegateMap3NodeGasLimit = 700000;

  @JsonKey(name: 'collectMap3NodeCreatorGasLimit81')
  int collectMap3NodeCreatorGasLimit81 = 2800000;

  @JsonKey(name: 'collectMap3NodeCreatorGasLimit61')
  int collectMap3NodeCreatorGasLimit61 = 2100000;

  @JsonKey(name: 'collectMap3NodeCreatorGasLimit41')
  int collectMap3NodeCreatorGasLimit41 = 1500000;

  @JsonKey(name: 'collectMap3NodeCreatorGasLimit21')
  int collectMap3NodeCreatorGasLimit21 = 800000;

  @JsonKey(name: 'collectMap3NodeCreatorGasLimit')
  int collectMap3NodeCreatorGasLimit = 800000;

  @JsonKey(name: 'collectMap3NodePartnerGasLimit')
  int collectMap3NodePartnerGasLimit = 80000;

  @JsonKey(name: 'collectHalfMap3NodeGasLimit')
  int collectHalfMap3NodeGasLimit = 150000;

  @JsonKey(name: 'canShareMap3Node')
  bool canShareMap3Node = true;

  @JsonKey(name: 'canCheckMap3Node')
  bool canCheckMap3Node = true;

  @JsonKey(name: 'canCheckMap3NodeCount')
  int canCheckMap3NodeCount = 1;

  @JsonKey(name: 'isOpenReStakingReward')
  bool isOpenReStakingReward = false;

  SystemConfigEntity(
    this.ethTransferGasLimit,
    this.erc20TransferGasLimit,
    this.erc20ApproveGasLimit,
    this.createMap3NodeGasLimit,
    this.delegateMap3NodeGasLimit,
    this.collectMap3NodeCreatorGasLimit81,
    this.collectMap3NodeCreatorGasLimit61,
    this.collectMap3NodeCreatorGasLimit41,
    this.collectMap3NodeCreatorGasLimit21,
    this.collectMap3NodeCreatorGasLimit,
    this.collectMap3NodePartnerGasLimit,
    this.collectHalfMap3NodeGasLimit,
    this.canShareMap3Node,
    this.canCheckMap3Node,
    this.canCheckMap3NodeCount,
    this.isOpenReStakingReward,
  );

  SystemConfigEntity.def();

  factory SystemConfigEntity.fromJson(Map<String, dynamic> srcJson) => _$SystemConfigEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SystemConfigEntityToJson(this);
}
