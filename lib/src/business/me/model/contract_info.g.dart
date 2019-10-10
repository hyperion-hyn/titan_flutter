// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractInfo _$ContractInfoFromJson(Map<String, dynamic> json) {
  return ContractInfo(
    json['id'] as int,
    (json['amount'] as num)?.toDouble(),
    json['power'] as int,
    (json['month_inc'] as num)?.toDouble(),
    json['limit'] as int,
    json['mission_req'] as int,
  );
}

Map<String, dynamic> _$ContractInfoToJson(ContractInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'power': instance.power,
      'month_inc': instance.monthInc,
      'limit': instance.limit,
      'mission_req': instance.missionReq,
    };
