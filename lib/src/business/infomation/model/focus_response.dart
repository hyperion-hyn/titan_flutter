import 'package:json_annotation/json_annotation.dart';

part 'focus_response.g.dart';

@JsonSerializable()
class FocusImage {
  String cover;
  String link;

  FocusImage(this.cover, this.link);

  factory FocusImage.fromJson(Map<String, dynamic> json) => _$FocusImageFromJson(json);

  Map<String, dynamic> toJson() => _$FocusImageToJson(this);
}
