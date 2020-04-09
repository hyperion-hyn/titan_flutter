import 'package:json_annotation/json_annotation.dart';

part 'pay_order.g.dart';

@JsonSerializable()
class PayOrder {
  String address;
  int amount;
  int order_id;
  String qr_code;
  int state;
  String hyn_amount;
  int is_free;
  double erc20USDTAmount;
  double hynUSDTAmount;

  PayOrder(
      {this.address,
      this.amount,
      this.order_id,
      this.qr_code,
      this.state,
      this.hyn_amount,
      this.erc20USDTAmount,
      this.hynUSDTAmount,
      this.is_free});

  factory PayOrder.fromJson(Map<String, dynamic> json) => _$PayOrderFromJson(json);

  Map<String, dynamic> toJson() => _$PayOrderToJson(this);
}
