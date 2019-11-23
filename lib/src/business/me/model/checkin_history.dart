import 'package:json_annotation/json_annotation.dart';

part 'checkin_history.g.dart';

@JsonSerializable()
class CheckinHistory {
  String day;
  int total;
  List<String> detail;

  CheckinHistory(this.day, this.total, this.detail);

  factory CheckinHistory.fromJson(Map<String, dynamic> json) => _$CheckinHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$CheckinHistoryToJson(this);
}