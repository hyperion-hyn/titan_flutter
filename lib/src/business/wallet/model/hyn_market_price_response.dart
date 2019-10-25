import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/business/wallet/model/hyn_market_price_info.dart';

part 'hyn_market_price_response.g.dart';

@JsonSerializable()
class HynMarketPriceResponse {
  double avgPrice;
  double avgCNYPrice;
  List<HynMarketPriceInfo> markets;
  int total;

  HynMarketPriceResponse(this.avgPrice, this.avgCNYPrice, this.markets, this.total);

  factory HynMarketPriceResponse.fromJson(Map<String, dynamic> json) => _$HynMarketPriceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HynMarketPriceResponseToJson(this);
}
