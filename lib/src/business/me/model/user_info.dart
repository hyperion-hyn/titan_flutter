import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "email")
  String email;
  @JsonKey(name: "parent_id")
  String parentId;
  @JsonKey(name: "balance")
  double balance;
  @JsonKey(name: "total_power")
  int totalPower;
  @JsonKey(name: "mortgage_nodes")
  int mortgageNodes;
  @JsonKey(name: "high_power")
  int highPower;
  @JsonKey(name: "low_power")
  int lowPower;
  @JsonKey(name: "total_invitations")
  int totalInvitations;
  @JsonKey(name: "level")
  String level;

  UserInfo(this.id, this.email, this.parentId, this.balance, this.totalPower, this.mortgageNodes, this.highPower,
      this.lowPower, this.totalInvitations, this.level);

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
