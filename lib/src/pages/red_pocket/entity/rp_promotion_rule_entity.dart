import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/utils/format_util.dart';

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
  String burn;

  @JsonKey(name: 'holding')
  String holding;

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

  String get burnStr => FormatUtil.weiToEtherStr(burn) ?? '0';
  String get holdingStr => FormatUtil.weiToEtherStr(holding) ?? '0';

  factory LevelRule.fromJson(Map<String, dynamic> srcJson) => _$LevelRuleFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LevelRuleToJson(this);
}

@JsonSerializable()
class SupplyInfo extends Object {
  @JsonKey(name: 'promotion_supply_ratio')
  String promotionSupplyRatio;

  @JsonKey(name: 'total_supply')
  String totalSupply;

  @JsonKey(name: 'random_min_level')
  int randomMinLevel;

  @JsonKey(name: 'gradient_ratio')
  double gradientRatio;

  SupplyInfo(
    this.promotionSupplyRatio,
    this.totalSupply,
      this.randomMinLevel,
      this.gradientRatio,
  );


  // String get promotionSupplyRatioStr => FormatUtil.weiToEtherStr(promotionSupplyRatio) ?? '0';
  String get totalSupplyStr => FormatUtil.weiToEtherStr(totalSupply) ?? '0';

  factory SupplyInfo.fromJson(Map<String, dynamic> srcJson) => _$SupplyInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SupplyInfoToJson(this);
}
