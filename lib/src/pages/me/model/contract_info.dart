import 'package:json_annotation/json_annotation.dart';

part 'contract_info.g.dart';

@JsonSerializable()
class ContractInfo {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "power")
  int power;
  @JsonKey(name: "month_inc")
  double monthInc;
  @JsonKey(name: "limit")
  int limit;
  @JsonKey(name: "mission_req")
  int missionReq;

  ContractInfo(this.id, this.amount, this.power, this.monthInc, this.limit, this.missionReq);

  factory ContractInfo.fromJson(Map<String, dynamic> json) => _$ContractInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContractInfoToJson(this);
}
