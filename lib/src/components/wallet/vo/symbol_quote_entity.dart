import 'package:json_annotation/json_annotation.dart';

part 'symbol_quote_entity.g.dart';


@JsonSerializable()
class SymbolQuoteEntity extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'btc_cny_price')
  double btcCnyPrice;

  @JsonKey(name: 'btc_usd_price')
  double btcUsdPrice;

  @JsonKey(name: 'btc_percent_change_cny24h')
  double btcPercentChangeCny24h;

  @JsonKey(name: 'btc_percent_change_usd24h')
  double btcPercentChangeUsd24h;

  @JsonKey(name: 'eth_cny_price')
  double ethCnyPrice;

  @JsonKey(name: 'eth_usd_price')
  double ethUsdPrice;

  @JsonKey(name: 'eth_percent_change_cny24h')
  double ethPercentChangeCny24h;

  @JsonKey(name: 'eth_percent_change_usd24h')
  double ethPercentChangeUsd24h;

  @JsonKey(name: 'hyn_cny_price')
  double hynCnyPrice;

  @JsonKey(name: 'hyn_usd_price')
  double hynUsdPrice;

  @JsonKey(name: 'hyn_percent_change_cny24h')
  double hynPercentChangeCny24h;

  @JsonKey(name: 'hyn_percent_change_usd24h')
  double hynPercentChangeUsd24h;

  @JsonKey(name: 'usdt_cny_price')
  double usdtCnyPrice;

  @JsonKey(name: 'usdt_usd_price')
  double usdtUsdPrice;

  @JsonKey(name: 'usdt_percent_change_cny24h')
  double usdtPercentChangeCny24h;

  @JsonKey(name: 'usdt_percent_change_usd24h')
  double usdtPercentChangeUsd24h;

  SymbolQuoteEntity(this.id,this.createdAt,this.updatedAt,this.btcCnyPrice,this.btcUsdPrice,this.btcPercentChangeCny24h,this.btcPercentChangeUsd24h,this.ethCnyPrice,this.ethUsdPrice,this.ethPercentChangeCny24h,this.ethPercentChangeUsd24h,this.hynCnyPrice,this.hynUsdPrice,this.hynPercentChangeCny24h,this.hynPercentChangeUsd24h,this.usdtCnyPrice,this.usdtUsdPrice,this.usdtPercentChangeCny24h,this.usdtPercentChangeUsd24h,);

  factory SymbolQuoteEntity.fromJson(Map<String, dynamic> srcJson) => _$SymbolQuoteEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SymbolQuoteEntityToJson(this);

}


