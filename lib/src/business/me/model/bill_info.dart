import 'package:json_annotation/json_annotation.dart';

part 'bill_info.g.dart';

@JsonSerializable()
class BillInfo {
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "sub_title")
  String subTitle;
  @JsonKey(name: "parent_id")
  int parentId;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "created_at")
  int crateAt;

  BillInfo(this.title, this.subTitle, this.parentId, this.amount, this.crateAt);

  factory BillInfo.fromJson(Map<String, dynamic> json) => _$BillInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BillInfoToJson(this);
}
