import 'package:json_annotation/json_annotation.dart'; 
  
part 'rp_promotion_entity.g.dart';


@JsonSerializable()
  class RpPromotionEntity extends Object {

  @JsonKey(name: 'rp_supply')
  RpSupply rpSupply;

  @JsonKey(name: 'rules')
  List<Rules> rules;

  @JsonKey(name: 'self')
  Self self;

  RpPromotionEntity(this.rpSupply,this.rules,this.self,);

  factory RpPromotionEntity.fromJson(Map<String, dynamic> srcJson) => _$RpPromotionEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpPromotionEntityToJson(this);

}

  
@JsonSerializable()
  class RpSupply extends Object {

  @JsonKey(name: 'promotion_supply_ratio')
  int promotionSupplyRatio;

  @JsonKey(name: 'total_supply')
  int totalSupply;

  RpSupply(this.promotionSupplyRatio,this.totalSupply,);

  factory RpSupply.fromJson(Map<String, dynamic> srcJson) => _$RpSupplyFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpSupplyToJson(this);

}

  
@JsonSerializable()
  class Rules extends Object {

  @JsonKey(name: 'burn')
  int burn;

  @JsonKey(name: 'holding')
  int holding;

  @JsonKey(name: 'holding_formula')
  String holdingFormula;

  @JsonKey(name: 'level')
  int level;

  Rules(this.burn,this.holding,this.holdingFormula,this.level,);

  factory Rules.fromJson(Map<String, dynamic> srcJson) => _$RulesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RulesToJson(this);

}

  
@JsonSerializable()
  class Self extends Object {

  @JsonKey(name: 'before_level')
  int beforeLevel;

  @JsonKey(name: 'current_burn')
  int currentBurn;

  @JsonKey(name: 'current_holding')
  int currentHolding;

  @JsonKey(name: 'current_level')
  int currentLevel;

  Self(this.beforeLevel,this.currentBurn,this.currentHolding,this.currentLevel,);

  factory Self.fromJson(Map<String, dynamic> srcJson) => _$SelfFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SelfToJson(this);

}

  
