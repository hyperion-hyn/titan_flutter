import 'package:json_annotation/json_annotation.dart';

part 'mortgage_info_v2.g.dart';

@JsonSerializable()
class MortgageInfoV2 {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  String icon;
  String description;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "income_rate")
  String incomeRate;
  @JsonKey(name: "snap_up_total")
  int snapUpTotal;
  @JsonKey(name: "snap_up_stocks")
  int snapUpStocks;


  MortgageInfoV2(this.id, this.name, this.icon, this.description, this.amount, this.incomeRate, this.snapUpTotal,
      this.snapUpStocks);

  factory MortgageInfoV2.fromJson(Map<String, dynamic> json) => _$MortgageInfoV2FromJson(json);

  Map<String, dynamic> toJson() => _$MortgageInfoV2ToJson(this);
}
