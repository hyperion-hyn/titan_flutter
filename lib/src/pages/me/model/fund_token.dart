import 'package:json_annotation/json_annotation.dart';

part 'fund_token.g.dart';

@JsonSerializable()
class FundToken {
  @JsonKey(name: "expire_at")
  int expireAt;
  @JsonKey(name: "token")
  String token;
  @JsonKey(name: "user_id")
  String userId;

  FundToken(this.expireAt, this.token, this.userId);

  factory FundToken.fromJson(Map<String, dynamic> json) => _$FundTokenFromJson(json);

  Map<String, dynamic> toJson() => _$FundTokenToJson(this);
}
