// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_config_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemConfigEntity _$SystemConfigEntityFromJson(Map<String, dynamic> json) {
  return SystemConfigEntity(
    json['ethTransferGasLimit'] as int ?? 21000,
    json['erc20TransferGasLimit'] as int ?? 55000,
    json['erc20ApproveGasLimit'] as int ?? 50000,
    json['createMap3NodeGasLimit'] as int ?? 560000,
    json['delegateMap3NodeGasLimit'] as int ?? 700000,
    json['collectMap3NodeCreatorGasLimit'] as int ?? 2800000,
    json['collectMap3NodePartnerGasLimit'] as int ?? 80000,
    json['collectHalfMap3NodeGasLimit'] as int ?? 150000,
  );
}

Map<String, dynamic> _$SystemConfigEntityToJson(SystemConfigEntity instance) =>
    <String, dynamic>{
      'ethTransferGasLimit': instance.ethTransferGasLimit,
      'erc20TransferGasLimit': instance.erc20TransferGasLimit,
      'erc20ApproveGasLimit': instance.erc20ApproveGasLimit,
      'createMap3NodeGasLimit': instance.createMap3NodeGasLimit,
      'delegateMap3NodeGasLimit': instance.delegateMap3NodeGasLimit,
      'collectMap3NodeCreatorGasLimit': instance.collectMap3NodeCreatorGasLimit,
      'collectMap3NodePartnerGasLimit': instance.collectMap3NodePartnerGasLimit,
      'collectHalfMap3NodeGasLimit': instance.collectHalfMap3NodeGasLimit,
    };
