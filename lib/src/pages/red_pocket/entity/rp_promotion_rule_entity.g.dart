// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_promotion_rule_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpPromotionRuleEntity _$RpPromotionRuleEntityFromJson(
    Map<String, dynamic> json) {
  return RpPromotionRuleEntity(
    (json['dynamic'] as List)
        ?.map((e) =>
            e == null ? null : LevelRule.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['static'] as List)
        ?.map((e) =>
            e == null ? null : LevelRule.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['supply_info'] == null
        ? null
        : SupplyInfo.fromJson(json['supply_info'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpPromotionRuleEntityToJson(
        RpPromotionRuleEntity instance) =>
    <String, dynamic>{
      'dynamic': instance.dynamicList?.map((e) => e?.toJson())?.toList(),
      'static': instance.static?.map((e) => e?.toJson())?.toList(),
      'supply_info': instance.supplyInfo?.toJson(),
    };

LevelRule _$LevelRuleFromJson(Map<String, dynamic> json) {
  return LevelRule(
    json['burn'] as String,
    json['holding'] as String,
    json['holding_formula'] as String,
    json['level'] as int,
    json['promotion_type'] as int,
  );
}

Map<String, dynamic> _$LevelRuleToJson(LevelRule instance) => <String, dynamic>{
      'burn': instance.burn,
      'holding': instance.holding,
      'holding_formula': instance.holdingFormula,
      'level': instance.level,
      'promotion_type': instance.promotionType,
    };

SupplyInfo _$SupplyInfoFromJson(Map<String, dynamic> json) {
  return SupplyInfo(
    json['promotion_supply_ratio'] as String,
    json['total_supply'] as String,
    json['random_min_level'] as int,
    (json['gradient_ratio'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$SupplyInfoToJson(SupplyInfo instance) =>
    <String, dynamic>{
      'promotion_supply_ratio': instance.promotionSupplyRatio,
      'total_supply': instance.totalSupply,
      'random_min_level': instance.randomMinLevel,
      'gradient_ratio': instance.gradientRatio,
    };
