import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_info.g.dart';

@JsonSerializable()
class WithdrawalInfo {
  double balance;
  double can_withdrawal;
  double free_rate;
  double has_withdrawal;
  double min_limit;

  WithdrawalInfo(this.balance, this.can_withdrawal, this.free_rate, this.has_withdrawal, this.min_limit);

  factory WithdrawalInfo.fromJson(Map<String, dynamic> json) => _$WithdrawalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalInfoToJson(this);

}