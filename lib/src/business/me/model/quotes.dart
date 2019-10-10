import 'package:json_annotation/json_annotation.dart';

part 'quotes.g.dart';

@JsonSerializable()
class Quotes {
  String currency;
  String to;
  double rate;

  Quotes(this.currency, this.to, this.rate);

  factory Quotes.fromJson(Map<String, dynamic> json) => _$QuotesFromJson(json);

  Map<String, dynamic> toJson() => _$QuotesToJson(this);
}