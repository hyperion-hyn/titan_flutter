import 'package:json_annotation/json_annotation.dart';

part 'user_level_info.g.dart';

@JsonSerializable()
class UserLevelInfo {
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "level")
  int level;
  @JsonKey(name: "description")
  String description;
  @JsonKey(name: "reward_rate")
  double rewardRate;

  UserLevelInfo(this.name, this.level, this.description, this.rewardRate);

  factory UserLevelInfo.fromJson(Map<String, dynamic> json) => _$UserLevelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserLevelInfoToJson(this);
}
