// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_info_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractInfoV2 _$ContractInfoV2FromJson(Map<String, dynamic> json) {
  return ContractInfoV2(
    json['id'] as int,
    json['name'] as String,
    json['icon'] as String,
    json['description'] as String,
    (json['amount'] as num)?.toDouble(),
    (json['hyn_amount'] as num)?.toDouble(),
    json['power'] as int,
    (json['month_inc'] as num)?.toDouble(),
    json['limit'] as int,
    json['mission_req'] as int,
    json['time_cycle'] as int,
    (json['total_income'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ContractInfoV2ToJson(ContractInfoV2 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'amount': instance.amount,
      'hyn_amount': instance.hynAmount,
      'power': instance.power,
      'month_inc': instance.monthInc,
      'limit': instance.limit,
      'mission_req': instance.missionReq,
      'time_cycle': instance.timeCycle,
      'total_income': instance.totalIncome,
    };
