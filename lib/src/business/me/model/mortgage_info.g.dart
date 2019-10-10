// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mortgage_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MortgageInfo _$MortgageInfoFromJson(Map<String, dynamic> json) {
  return MortgageInfo(
    json['id'] as int,
    json['name'] as String,
    (json['amount'] as num)?.toDouble(),
    json['income_rate'] as String,
  );
}

Map<String, dynamic> _$MortgageInfoToJson(MortgageInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'income_rate': instance.incomeRate,
    };
