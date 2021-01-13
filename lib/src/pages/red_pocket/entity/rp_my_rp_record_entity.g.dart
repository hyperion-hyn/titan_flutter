// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_my_rp_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpMyRpRecordEntity _$RpMyRpRecordEntityFromJson(Map<String, dynamic> json) {
  return RpMyRpRecordEntity(
    (json['data'] as List)
        ?.map((e) => e == null
            ? null
            : RpOpenRecordEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['paging_key'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$RpMyRpRecordEntityToJson(RpMyRpRecordEntity instance) =>
    <String, dynamic>{
      'data': instance.data,
      'paging_key': instance.pagingKey,
    };


RpMyRpSplitRecordEntity _$RpMyRpSplitRecordEntityFromJson(Map<String, dynamic> json) {
  return RpMyRpSplitRecordEntity(
    (json['data'] as List)
        ?.map((e) => e == null
        ? null
        : RpOpenRecordEntity.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['paging_key'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$RpMyRpSplitRecordEntityToJson(RpMyRpSplitRecordEntity instance) =>
    <String, dynamic>{
      'data': instance.data,
      'paging_key': instance.pagingKey,
    };




RpOpenRecordEntity _$RpOpenRecordEntityFromJson(Map<String, dynamic> json) {
  return RpOpenRecordEntity(
    json['address'] as String,
    json['amount'] as String,
    json['id'] as String,
    json['luck'] as int,
    json['red_pocket_id'] as int,
    json['created_at'] as int,
    json['total_amount'] as String,
    json['type'] as int,
    json['username'] as String,
    json['from'] as int,
    json['to'] as int,
    json['other_user_count'] as int,
    json['other_user_amount'] as String,
    json['role'] as int,
    json['level'] as int,
    json['tx_hash'] as String,
  );
}

Map<String, dynamic> _$RpOpenRecordEntityToJson(RpOpenRecordEntity instance) =>
    <String, dynamic>{
      'address': instance.address,
      'amount': instance.amount,
      'id': instance.id,
      'luck': instance.luck,
      'red_pocket_id': instance.redPocketId,
      'created_at': instance.createdAt,
      'total_amount': instance.totalAmount,
      'type': instance.type,
      'username': instance.username,
      'from': instance.from,
      'to': instance.to,
      'other_user_count': instance.otherUserCount,
      'other_user_amount': instance.otherUserAmount,
      'role': instance.role,
      'level': instance.level,
    };
