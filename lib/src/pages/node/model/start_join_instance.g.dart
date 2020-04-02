// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_join_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartJoinInstance _$StartJoinInstanceFromJson(Map<String, dynamic> json) {
  return StartJoinInstance(
    json['address'] as String,
    json['name'] as String,
    json['amount'] as double,
    json['data'] as String,
    approveData: json['approveData'] as String,
    createData: json['createData'] as String,
  );
}

Map<String, dynamic> _$StartJoinInstanceToJson(StartJoinInstance instance) =>
    <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'amount': instance.amount,
      'data': instance.data,
      'approveData': instance.approveData,
      'createData': instance.createData,
    };
