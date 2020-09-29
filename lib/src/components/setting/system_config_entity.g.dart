// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_config_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
    json['canShareMap3Node'] as bool ?? true,
    json['canCheckMap3Node'] as bool ?? true,
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
      'canShareMap3Node': instance.canShareMap3Node,
      'canCheckMap3Node': instance.canCheckMap3Node,
    };
