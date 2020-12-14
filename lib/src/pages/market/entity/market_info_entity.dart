import 'package:json_annotation/json_annotation.dart';

part 'market_info_entity.g.dart';

@JsonSerializable()
class MarketInfoEntity extends Object {
  @JsonKey(name: 'best_bid')
  int bestBid;

  @JsonKey(name: 'best_ask')
  int bestAsk;

  @JsonKey(name: 'amount_precision')
  int amountPrecision;

  @JsonKey(name: 'price_precision')
  int pricePrecision;

  @JsonKey(name: 'amount_max')
  int amountMax;

  @JsonKey(name: 'amount_min')
  double amountMin;

  @JsonKey(name: 'fee_rate')
  double feeRate;

  @JsonKey(name: 'fee_rate_readable')
  double feeRateReadable;

  @JsonKey(name: 'turnover_precision')
  int turnoverPrecision;

  @JsonKey(name: 'depth_precision')
  List<int> depthPrecision;

  MarketInfoEntity(
    this.amountPrecision,
    this.pricePrecision,
    this.turnoverPrecision,
    this.amountMax,
    this.amountMin,
    this.depthPrecision,
  );

  MarketInfoEntity.defaultEntity(this.amountPrecision, this.pricePrecision, this.turnoverPrecision, this.amountMax,
      this.amountMin, this.depthPrecision);

  factory MarketInfoEntity.fromJson(Map<String, dynamic> srcJson) => _$MarketInfoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$MarketInfoEntityToJson(this);
}
