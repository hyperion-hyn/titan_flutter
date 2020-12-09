import 'package:json_annotation/json_annotation.dart';

part 'rp_promotion_rule_entity.g.dart';

@JsonSerializable()
class RpPromotionRuleEntity extends Object {
  @JsonKey(name: 'dynamic')
  List<LevelRule> dynamicList;

  @JsonKey(name: 'static')
  List<LevelRule> static;

  @JsonKey(name: 'supply_info')
  SupplyInfo supplyInfo;

  RpPromotionRuleEntity(
    this.dynamicList,
    this.static,
    this.supplyInfo,
  );

  factory RpPromotionRuleEntity.fromJson(Map<String, dynamic> srcJson) => _$RpPromotionRuleEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpPromotionRuleEntityToJson(this);
}

@JsonSerializable()
class LevelRule extends Object {
  @JsonKey(name: 'burn')
  int burn;

  @JsonKey(name: 'holding')
  int holding;

  @JsonKey(name: 'holding_formula')
  String holdingFormula;

  @JsonKey(name: 'level')
  int level;

  @JsonKey(name: 'promotion_type')
  int promotionType;

  LevelRule(
    this.burn,
    this.holding,
    this.holdingFormula,
    this.level,
    this.promotionType,
  );

  factory LevelRule.fromJson(Map<String, dynamic> srcJson) => _$LevelRuleFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LevelRuleToJson(this);
}

@JsonSerializable()
class SupplyInfo extends Object {
  @JsonKey(name: 'promotion_supply_ratio')
  int promotionSupplyRatio;

  @JsonKey(name: 'total_supply')
  int totalSupply;

  SupplyInfo(
    this.promotionSupplyRatio,
    this.totalSupply,
  );

  factory SupplyInfo.fromJson(Map<String, dynamic> srcJson) => _$SupplyInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SupplyInfoToJson(this);
}
