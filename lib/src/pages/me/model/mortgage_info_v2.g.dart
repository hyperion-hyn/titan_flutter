// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mortgage_info_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MortgageInfoV2 _$MortgageInfoV2FromJson(Map<String, dynamic> json) {
  return MortgageInfoV2(
    json['id'] as int,
    json['name'] as String,
    json['icon'] as String,
    json['description'] as String,
    (json['amount'] as num)?.toDouble(),
    json['income_rate'] as String,
    json['income_cycle'] as int,
    json['snap_up_total'] as int,
    json['snap_up_stocks'] as int,
  );
}

Map<String, dynamic> _$MortgageInfoV2ToJson(MortgageInfoV2 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'amount': instance.amount,
      'income_rate': instance.incomeRate,
      'income_cycle': instance.incomeCycle,
      'snap_up_total': instance.snapUpTotal,
      'snap_up_stocks': instance.snapUpStocks,
    };
