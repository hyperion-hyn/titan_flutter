import 'package:json_annotation/json_annotation.dart';

part 'history_search.g.dart';

@JsonSerializable()
class HistorySearchEntity {
  int id;
  final double time;
  @JsonKey(name: 'search_text')
  final String searchText;
  String type;

  HistorySearchEntity({this.id, this.time, this.searchText, this.type});

  Map<String, Object> toJson() => _$HistorySearchEntityToJson(this);

  factory HistorySearchEntity.fromJson(Map<String, Object> json) => _$HistorySearchEntityFromJson(json);

  @override
  String toString() {
    return toJson().toString();
  }
}
