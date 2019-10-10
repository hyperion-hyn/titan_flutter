import 'package:json_annotation/json_annotation.dart';

part 'power_detail.g.dart';

@JsonSerializable()
class PowerDetail {
  @JsonKey(name: "contract_id")
  int contractId;
  @JsonKey(name: "order_id")
  int orderId;
  @JsonKey(name: "power")
  int power;
  @JsonKey(name: "amount")
  double amount;
  @JsonKey(name: "month_inc")
  double monthInc;
  @JsonKey(name: "pay_type")
  String payType;
  @JsonKey(name: "expired_at")
  int expiredAt;
  @JsonKey(name: "expire")
  bool expire;
  @JsonKey(name: "created_at")
  int createdAt;

  PowerDetail(this.contractId, this.orderId, this.power, this.amount, this.monthInc, this.payType,
      this.expiredAt, this.expire, this.createdAt);

  factory PowerDetail.fromJson(Map<String, dynamic> json) => _$PowerDetailFromJson(json);

  Map<String, dynamic> toJson() => _$PowerDetailToJson(this);
}
