import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_info_log.g.dart';

@JsonSerializable()
class WithdrawalInfoLog {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "fee")
  double fee;
  @JsonKey(name: "created_at")
  int createAt;
  @JsonKey(name: "state")
  String state;
  @JsonKey(name: "state_title")
  String stateTitle;
  String hash;

  WithdrawalInfoLog(this.id, this.amount, this.fee, this.createAt, this.state, this.stateTitle, this.hash);

  factory WithdrawalInfoLog.fromJson(Map<String, dynamic> json) => _$WithdrawalInfoLogFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalInfoLogToJson(this);
}
