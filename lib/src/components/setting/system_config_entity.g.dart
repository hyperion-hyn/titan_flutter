// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_config_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemConfigEntity _$SystemConfigEntityFromJson(Map<String, dynamic> json) {
  return SystemConfigEntity(
    json['ethTransferGasLimit'] as int,
    json['erc20TransferGasLimit'] as int,
    json['erc20ApproveGasLimit'] as int,
    json['createMap3NodeGasLimit'] as int,
    json['delegateMap3NodeGasLimit'] as int,
    json['collectMap3NodeCreatorGasLimit81'] as int,
    json['collectMap3NodeCreatorGasLimit61'] as int,
    json['collectMap3NodeCreatorGasLimit41'] as int,
    json['collectMap3NodeCreatorGasLimit21'] as int,
    json['collectMap3NodeCreatorGasLimit'] as int,
    json['collectMap3NodePartnerGasLimit'] as int,
    json['collectHalfMap3NodeGasLimit'] as int,
    json['canShareMap3Node'] as bool,
    json['canCheckMap3Node'] as bool,
    json['canCheckMap3NodeCount'] as int,
    json['isOpenReStakingReward'] as bool,
    json['collectRpTransmitGasLimit'] as int,
  );
}

Map<String, dynamic> _$SystemConfigEntityToJson(SystemConfigEntity instance) => <String, dynamic>{
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
      'canShareMap3Node': instance.canShareMap3Node,
      'canCheckMap3Node': instance.canCheckMap3Node,
      'canCheckMap3NodeCount': instance.canCheckMap3NodeCount,
      'isOpenReStakingReward': instance.isOpenReStakingReward,
      'collectRpTransmitGasLimit': instance.collectRpTransmitGasLimit,
    };
