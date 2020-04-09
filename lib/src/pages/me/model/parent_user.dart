import 'package:json_annotation/json_annotation.dart';

part 'parent_user.g.dart';

@JsonSerializable()
class ParentUser {
  String email;
  String invitation_code;

  ParentUser(this.email, this.invitation_code);


  factory ParentUser.fromJson(Map<String, dynamic> json) =>
      _$ParentUserFromJson(json);

  Map<String, dynamic> toJson() => _$ParentUserToJson(this);
}
