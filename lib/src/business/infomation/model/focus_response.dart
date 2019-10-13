import 'package:json_annotation/json_annotation.dart';

part 'focus_response.g.dart';

@JsonSerializable()
class Focus {
  String cover;
  String link;

  Focus(this.cover, this.link);

  factory Focus.fromJson(Map<String, dynamic> json) => _$FocusFromJson(json);

  Map<String, dynamic> toJson() => _$FocusToJson(this);
}
