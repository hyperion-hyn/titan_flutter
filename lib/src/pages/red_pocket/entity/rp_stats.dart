import 'package:json_annotation/json_annotation.dart';

part 'rp_stats.g.dart';

@JsonSerializable()
class RpStats extends Object {
  @JsonKey(name: 'global')
  Global global;

  @JsonKey(name: 'airdrop')
  Airdrop airdrop;

  @JsonKey(name: 'transmit')
  Transmit transmit;

  @JsonKey(name: 'promotion')
  Promotion promotion;

  RpStats(
    this.global,
    this.airdrop,
    this.transmit,
    this.promotion,
  );

  factory RpStats.fromJson(Map<String, dynamic> srcJson) =>
      _$RpStatsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RpStatsToJson(this);
}

@JsonSerializable()
class Global extends Object {
  @JsonKey(name: 'total_cap')
  String totalCap;

  @JsonKey(name: 'total_supply')
  String totalSupply;

  @JsonKey(name: 'total_burning')
  String totalBurning;

  Global(
    this.totalCap,
    this.totalSupply,
    this.totalBurning,
  );

  factory Global.fromJson(Map<String, dynamic> srcJson) =>
      _$GlobalFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GlobalToJson(this);
}

@JsonSerializable()
class Airdrop extends Object {
  @JsonKey(name: 'total')
  String total;

  @JsonKey(name: 'total_airdrop')
  String totalAirdrop;

  @JsonKey(name: 'lucky_total')
  String luckyTotal;

  @JsonKey(name: 'level_total')
  String levelTotal;

  @JsonKey(name: 'promotion_total')
  String promotionTotal;

  @JsonKey(name: 'burning_total')
  String burningTotal;

  Airdrop(
    this.total,
    this.totalAirdrop,
    this.luckyTotal,
    this.levelTotal,
    this.promotionTotal,
    this.burningTotal,
  );

  factory Airdrop.fromJson(Map<String, dynamic> srcJson) =>
      _$AirdropFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AirdropToJson(this);
}

@JsonSerializable()
class Transmit extends Object {
  @JsonKey(name: 'total')
  String total;

  @JsonKey(name: 'holding_hyn')
  String holdingHyn;

  @JsonKey(name: 'transmit_rp')
  String transmitRp;

  Transmit(
    this.total,
    this.holdingHyn,
    this.transmitRp,
  );

  factory Transmit.fromJson(Map<String, dynamic> srcJson) =>
      _$TransmitFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TransmitToJson(this);
}

@JsonSerializable()
class Promotion extends Object {
  @JsonKey(name: 'total_holding')
  String totalHolding;

  @JsonKey(name: 'total_burning')
  String totalBurning;

  Promotion(
    this.totalHolding,
    this.totalBurning,
  );

  factory Promotion.fromJson(Map<String, dynamic> srcJson) =>
      _$PromotionFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);
}
