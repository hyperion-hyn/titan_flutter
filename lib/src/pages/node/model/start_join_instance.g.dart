// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_join_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartJoinInstance _$StartJoinInstanceFromJson(Map<String, dynamic> json) {
  return StartJoinInstance(
    json['address'] as String,
    json['name'] as String,
    (json['amount'] as num)?.toDouble(),
    json['data'] as String,
  );
}

Map<String, dynamic> _$StartJoinInstanceToJson(StartJoinInstance instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'amount': instance.amount,
      'data': instance.data,
    };
