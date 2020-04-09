// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_mortgage_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeMortgageInfo _$NodeMortgageInfoFromJson(Map<String, dynamic> json) {
  return NodeMortgageInfo(
    json['id'] as int,
    json['name'] as String,
    (json['amount'] as num)?.toDouble(),
    json['created_at'] as int,
    json['active'] as bool,
  );
}

Map<String, dynamic> _$NodeMortgageInfoToJson(NodeMortgageInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'created_at': instance.createAt,
      'active': instance.active,
    };
