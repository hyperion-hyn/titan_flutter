import 'package:json_annotation/json_annotation.dart';

part 'hyn_market_price_info.g.dart';

@JsonSerializable()
class HynMarketPriceInfo {
  String source;
  String icon;
  @JsonKey(name: "tx_pair")
  String txPair;
  double price;
  @JsonKey(name: "is_best")
  bool isBest;
  String url;

  HynMarketPriceInfo(this.source, this.icon, this.txPair, this.price, this.isBest, this.url);

  factory HynMarketPriceInfo.fromJson(Map<String, dynamic> json) => _$HynMarketPriceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$HynMarketPriceInfoToJson(this);
}
