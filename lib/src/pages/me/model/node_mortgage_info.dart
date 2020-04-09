import 'package:json_annotation/json_annotation.dart';

part 'node_mortgage_info.g.dart';

@JsonSerializable()
class NodeMortgageInfo {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "created_at")
  int createAt;
  @JsonKey(name: "active")
  bool active;

  NodeMortgageInfo(this.id, this.name, this.amount, this.createAt, this.active);

  factory NodeMortgageInfo.fromJson(Map<String, dynamic> json) => _$NodeMortgageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NodeMortgageInfoToJson(this);
}
