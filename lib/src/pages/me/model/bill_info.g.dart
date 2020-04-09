// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillInfo _$BillInfoFromJson(Map<String, dynamic> json) {
  return BillInfo(
    json['title'] as String,
    json['sub_title'] as String,
    json['parent_id'] as int,
    (json['amount'] as num)?.toDouble(),
    json['created_at'] as int,
    json['has_detail'] as bool,
    json['id'] as int,
  );
}

Map<String, dynamic> _$BillInfoToJson(BillInfo instance) => <String, dynamic>{
      'title': instance.title,
      'sub_title': instance.subTitle,
      'parent_id': instance.parentId,
      'amount': instance.amount,
      'created_at': instance.crateAt,
      'has_detail': instance.hasDetail,
      'id': instance.id,
    };
