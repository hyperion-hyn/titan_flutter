// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_promotion_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpPromotionEntity _$RpPromotionEntityFromJson(Map<String, dynamic> json) {
  return RpPromotionEntity(
    json['rp_supply'] == null
        ? null
        : RpSupply.fromJson(json['rp_supply'] as Map<String, dynamic>),
    (json['rules'] as List)
        ?.map(
            (e) => e == null ? null : Rules.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['self'] == null
        ? null
        : Self.fromJson(json['self'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpPromotionEntityToJson(RpPromotionEntity instance) =>
    <String, dynamic>{
      'rp_supply': instance.rpSupply,
      'rules': instance.rules,
      'self': instance.self,
    };

RpSupply _$RpSupplyFromJson(Map<String, dynamic> json) {
  return RpSupply(
    json['promotion_supply_ratio'] as int,
    json['total_supply'] as int,
  );
}

Map<String, dynamic> _$RpSupplyToJson(RpSupply instance) => <String, dynamic>{
      'promotion_supply_ratio': instance.promotionSupplyRatio,
      'total_supply': instance.totalSupply,
    };

Rules _$RulesFromJson(Map<String, dynamic> json) {
  return Rules(
    json['burn'] as int,
    json['holding'] as int,
    json['holding_formula'] as String,
    json['level'] as int,
  );
}

Map<String, dynamic> _$RulesToJson(Rules instance) => <String, dynamic>{
      'burn': instance.burn,
      'holding': instance.holding,
      'holding_formula': instance.holdingFormula,
      'level': instance.level,
    };

Self _$SelfFromJson(Map<String, dynamic> json) {
  return Self(
    json['before_level'] as int,
    json['current_burn'] as int,
    json['current_holding'] as int,
    json['current_level'] as int,
  );
}

Map<String, dynamic> _$SelfToJson(Self instance) => <String, dynamic>{
      'before_level': instance.beforeLevel,
      'current_burn': instance.currentBurn,
      'current_holding': instance.currentHolding,
      'current_level': instance.currentLevel,
    };
