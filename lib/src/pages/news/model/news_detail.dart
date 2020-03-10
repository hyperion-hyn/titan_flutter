import 'package:json_annotation/json_annotation.dart';
import './focus_response.dart';

part 'news_detail.g.dart';

@JsonSerializable()
class NewsDetail {
  int id;
  int date;
  String title;
  String content;
  @JsonKey(name: "custom_cover")
  String customCover;
  String outlink;
  FocusImage focus;

  NewsDetail(this.id, this.date, this.title, this.content, this.customCover, this.outlink, this.focus);

  factory NewsDetail.fromJson(Map<String, dynamic> json) => _$NewsDetailFromJson(json);

  Map<String, dynamic> toJson() => _$NewsDetailToJson(this);
}
