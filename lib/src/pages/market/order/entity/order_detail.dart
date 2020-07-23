import 'package:json_annotation/json_annotation.dart';

part 'order_detail.g.dart';

@JsonSerializable()
class OrderDetail extends Object {
  @JsonKey(name: 'side')
  int side;

  @JsonKey(name: 'oid')
  String oid;

  @JsonKey(name: 'price')
  double price;

  @JsonKey(name: 'amount')
  double amount;

  @JsonKey(name: 'time')
  String time;

  @JsonKey(name: 'fee')
  double fee;

  OrderDetail(
    this.side,
    this.oid,
    this.price,
    this.amount,
    this.time,
    this.fee,
  );

  factory OrderDetail.fromJson(Map<String, dynamic> srcJson) =>
      _$OrderDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$OrderDetailToJson(this);
}
