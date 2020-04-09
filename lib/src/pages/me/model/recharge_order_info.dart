import 'package:json_annotation/json_annotation.dart';

part 'recharge_order_info.g.dart';

@JsonSerializable()
class RechargeOrderInfo {
  String address;
  double amount;
  @JsonKey(name: "order_id")
  int orderId;
  @JsonKey(name: "qr_code")
  String qrCode;
  int state;
  @JsonKey(name: "hyn_amount")
  String hynAmount;

  RechargeOrderInfo(this.address, this.amount, this.orderId, this.qrCode, this.state, this.hynAmount);

  factory RechargeOrderInfo.fromJson(Map<String, dynamic> json) => _$RechargeOrderInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RechargeOrderInfoToJson(this);
}
