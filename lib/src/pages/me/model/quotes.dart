import 'package:json_annotation/json_annotation.dart';

part 'quotes.g.dart';

@JsonSerializable()
class Quotes {
  String currency;
  String to;
  double rate;
  double avgRate;

  Quotes(this.currency, this.to, this.rate, this.avgRate);

  factory Quotes.fromJson(Map<String, dynamic> json) => _$QuotesFromJson(json);

  Map<String, dynamic> toJson() => _$QuotesToJson(this);
}
