import 'package:json_annotation/json_annotation.dart';

part 'contract_info_v2.g.dart';

@JsonSerializable()
class ContractInfoV2 {
  @JsonKey(name: "id")
  int id;
  String name;
  String icon;
  String description;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "hyn_amount")
  double hynAmount;
  @JsonKey(name: "power")
  int power;
  @JsonKey(name: "month_inc")
  double monthInc;
  @JsonKey(name: "limit")
  int limit;
  int remaining;
  @JsonKey(name: "mission_req")
  int missionReq;
  @JsonKey(name: "time_cycle")
  int timeCycle;
  @JsonKey(name: "total_income")
  double totalIncome;
  @JsonKey(name: "type")
  int type;
  ContractInfoV2(this.id, this.name, this.icon, this.description, this.amount, this.hynAmount, this.power,
      this.monthInc, this.limit, this.remaining, this.missionReq, this.timeCycle, this.totalIncome, this.type);

  factory ContractInfoV2.fromJson(Map<String, dynamic> json) => _$ContractInfoV2FromJson(json);

  Map<String, dynamic> toJson() => _$ContractInfoV2ToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
