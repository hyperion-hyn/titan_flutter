import 'package:json_annotation/json_annotation.dart';

part 'user_token.g.dart';

@JsonSerializable()
class UserToken {
  @JsonKey(name: "refresh_token")
  String refreshToken;
  String token;
  @JsonKey(name: "user_id")
  String userId;

  UserToken(this.refreshToken, this.token, this.userId);

  factory UserToken.fromJson(Map<String, dynamic> json) => _$UserTokenFromJson(json);

  Map<String, dynamic> toJson() => _$UserTokenToJson(this);
}
