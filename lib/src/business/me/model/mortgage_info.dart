import 'package:json_annotation/json_annotation.dart';

part 'mortgage_info.g.dart';

@JsonSerializable()
class MortgageInfo {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "income_rate")
  String incomeRate;

  MortgageInfo(this.id, this.name, this.amount, this.incomeRate);

  factory MortgageInfo.fromJson(Map<String, dynamic> json) => _$MortgageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MortgageInfoToJson(this);
}
