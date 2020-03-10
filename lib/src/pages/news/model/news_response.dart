import 'package:json_annotation/json_annotation.dart';
import './focus_response.dart';

part 'news_response.g.dart';

@JsonSerializable()
class NewsResponse {
  int id;
  int date;
  String title;
  @JsonKey(name: "custom_cover")
  String customCover;
  String outlink;
  FocusImage focus;

  NewsResponse(this.id, this.date, this.title, this.customCover, this.outlink, this.focus);

  factory NewsResponse.fromJson(Map<String, dynamic> json) => _$NewsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NewsResponseToJson(this);
}
