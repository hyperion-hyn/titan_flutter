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
  @JsonKey(name: "num_of_team_member")
  int numOfTeamMember;
  @JsonKey(name: "directly_power")
  int directlyPower;

  PromotionInfo(this.email, this.total, this.highest, this.secondHighest, this.low, this.numOfTeamMember, this.directlyPower);

  factory PromotionInfo.fromJson(Map<String, dynamic> json) => _$PromotionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionInfoToJson(this);
}
