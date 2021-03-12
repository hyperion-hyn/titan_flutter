import 'package:json_annotation/json_annotation.dart';

class SystemConfigEntity extends Object {
  @JsonKey(name: 'ethTransferGasLimit')
  int ethTransferGasLimit = 21000;

  @JsonKey(name: 'erc20TransferGasLimit')
  int erc20TransferGasLimit = 60000;

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

  @JsonKey(name: 'emptyDefaultGasLimit')
  int emptyDefaultGasLimit = 100000;

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
    this.emptyDefaultGasLimit,
    this.canShareMap3Node,
    this.canCheckMap3Node,
    this.canCheckMap3NodeCount,
    this.isOpenReStakingReward,
  );

  SystemConfigEntity.def();

  factory SystemConfigEntity.fromJson(Map<String, dynamic> srcJson) => _$SystemConfigEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SystemConfigEntityToJson(this);
}

SystemConfigEntity _$SystemConfigEntityFromJson(Map<String, dynamic> json) {
  return SystemConfigEntity(
    json['ethTransferGasLimit'] as int ?? 21000,
    json['erc20TransferGasLimit'] as int ?? 65000,
    json['erc20ApproveGasLimit'] as int ?? 50000,
    json['createMap3NodeGasLimit'] as int ?? 560000,
    json['delegateMap3NodeGasLimit'] as int ?? 700000,
    json['collectMap3NodeCreatorGasLimit81'] as int ?? 2800000,
    json['collectMap3NodeCreatorGasLimit61'] as int ?? 2100000,
    json['collectMap3NodeCreatorGasLimit41'] as int ?? 1500000,
    json['collectMap3NodeCreatorGasLimit21'] as int ?? 800000,
    json['collectMap3NodeCreatorGasLimit'] as int ?? 800000,
    json['collectMap3NodePartnerGasLimit'] as int ?? 80000,
    json['collectHalfMap3NodeGasLimit'] as int ?? 150000,
    json['emptyDefaultGasLimit'] as int ?? 100000,
    json['canShareMap3Node'] as bool ?? true,
    json['canCheckMap3Node'] as bool ?? true,
    json['canCheckMap3NodeCount'] as int ?? 1,
    json['isOpenReStakingReward'] as bool ?? false,
  );
}

Map<String, dynamic> _$SystemConfigEntityToJson(SystemConfigEntity instance) =>
    <String, dynamic>{
      'ethTransferGasLimit': instance.ethTransferGasLimit,
      'erc20TransferGasLimit': instance.erc20TransferGasLimit,
      'erc20ApproveGasLimit': instance.erc20ApproveGasLimit,
      'createMap3NodeGasLimit': instance.createMap3NodeGasLimit,
      'delegateMap3NodeGasLimit': instance.delegateMap3NodeGasLimit,
      'collectMap3NodeCreatorGasLimit81': instance.collectMap3NodeCreatorGasLimit81,
      'collectMap3NodeCreatorGasLimit61': instance.collectMap3NodeCreatorGasLimit61,
      'collectMap3NodeCreatorGasLimit41': instance.collectMap3NodeCreatorGasLimit41,
      'collectMap3NodeCreatorGasLimit21': instance.collectMap3NodeCreatorGasLimit21,
      'collectMap3NodeCreatorGasLimit': instance.collectMap3NodeCreatorGasLimit,
      'collectMap3NodePartnerGasLimit': instance.collectMap3NodePartnerGasLimit,
      'collectHalfMap3NodeGasLimit': instance.collectHalfMap3NodeGasLimit,
      'emptyDefaultGasLimit': instance.emptyDefaultGasLimit,
      'canShareMap3Node': instance.canShareMap3Node,
      'canCheckMap3Node': instance.canCheckMap3Node,
      'canCheckMap3NodeCount': instance.canCheckMap3NodeCount,
      'isOpenReStakingReward': instance.isOpenReStakingReward,
    };