import 'package:json_annotation/json_annotation.dart';

part 'promotion_info.g.dart';

@JsonSerializable()
class PromotionInfo {
  String email;
  int total;
  int highest;
  @JsonKey(name: "second_highest")
  int secondHighest;
  int low;

  PromotionInfo(this.email, this.total, this.highest, this.secondHighest, this.low);

  factory PromotionInfo.fromJson(Map<String, dynamic> json) => _$PromotionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionInfoToJson(this);
}
