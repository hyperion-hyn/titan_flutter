import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
part 'checkin_history.g.dart';

@JsonSerializable()
class CheckinHistory {
  String day;
  int total;
  CheckInDetail detail;

  CheckinHistory(this.day, this.total, this.detail);

  factory CheckinHistory.fromJson(Map<String, dynamic> json) => _$CheckinHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$CheckinHistoryToJson(this);
}