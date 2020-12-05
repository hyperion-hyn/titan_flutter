// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_detail_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpDetailEntity _$RpDetailEntityFromJson(Map<String, dynamic> json) {
  return RpDetailEntity(
    json['level_intro'] == null
        ? null
        : LevelIntro.fromJson(json['level_intro'] as Map<String, dynamic>),
    json['lucky_intro'] == null
        ? null
        : LuckyIntro.fromJson(json['lucky_intro'] as Map<String, dynamic>),
    json['promotion_intro'] == null
        ? null
        : PromotionIntro.fromJson(
            json['promotion_intro'] as Map<String, dynamic>),
    (json['records'] as List)
        ?.map((e) =>
            e == null ? null : Records.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['red_pocket'] == null
        ? null
        : RedPocket.fromJson(json['red_pocket'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpDetailEntityToJson(RpDetailEntity instance) =>
    <String, dynamic>{
      'level_intro': instance.levelIntro,
      'lucky_intro': instance.luckyIntro,
      'promotion_intro': instance.promotionIntro,
      'records': instance.records,
      'red_pocket': instance.redPocket,
    };

LevelIntro _$LevelIntroFromJson(Map<String, dynamic> json) {
  return LevelIntro(
    json['level'] as int,
    json['other_user_amount'] as int,
    json['other_user_count'] as int,
  );
}

Map<String, dynamic> _$LevelIntroToJson(LevelIntro instance) =>
    <String, dynamic>{
      'level': instance.level,
      'other_user_amount': instance.otherUserAmount,
      'other_user_count': instance.otherUserCount,
    };

LuckyIntro _$LuckyIntroFromJson(Map<String, dynamic> json) {
  return LuckyIntro(
    json['amount'] as int,
    json['luck'] as int,
  );
}

Map<String, dynamic> _$LuckyIntroToJson(LuckyIntro instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'luck': instance.luck,
    };

PromotionIntro _$PromotionIntroFromJson(Map<String, dynamic> json) {
  return PromotionIntro(
    json['address'] as String,
    json['from'] as int,
    json['name'] as String,
    json['to'] as int,
  );
}

Map<String, dynamic> _$PromotionIntroToJson(PromotionIntro instance) =>
    <String, dynamic>{
      'address': instance.address,
      'from': instance.from,
      'name': instance.name,
      'to': instance.to,
    };

Records _$RecordsFromJson(Map<String, dynamic> json) {
  return Records(
    json['address'] as String,
    json['amount'] as int,
    json['level'] as int,
    json['luck'] as int,
    json['name'] as String,
  );
}

Map<String, dynamic> _$RecordsToJson(Records instance) => <String, dynamic>{
      'address': instance.address,
      'amount': instance.amount,
      'level': instance.level,
      'luck': instance.luck,
      'name': instance.name,
    };

RedPocket _$RedPocketFromJson(Map<String, dynamic> json) {
  return RedPocket(
    json['amount'] as int,
    json['id'] as int,
    json['luck'] as int,
    json['time'] as String,
    json['total_amount'] as int,
    json['type'] as int,
  );
}

Map<String, dynamic> _$RedPocketToJson(RedPocket instance) => <String, dynamic>{
      'amount': instance.amount,
      'id': instance.id,
      'luck': instance.luck,
      'time': instance.time,
      'total_amount': instance.totalAmount,
      'type': instance.type,
    };
