import 'package:json_annotation/json_annotation.dart';

part 'purchase_order_info.g.dart';

@JsonSerializable()
class PurchaseOrderInfo {
  String address;
  int amount;
  @JsonKey(name: "order_id")
  int orderId;
  @JsonKey(name: "qr_code")
  String qrCode;
  int state;
  @JsonKey(name: "hyn_amount")
  String hynAmount;

  PurchaseOrderInfo(this.address, this.amount, this.orderId, this.qrCode, this.state, this.hynAmount);

  factory PurchaseOrderInfo.fromJson(Map<String, dynamic> json) => _$PurchaseOrderInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderInfoToJson(this);
}
