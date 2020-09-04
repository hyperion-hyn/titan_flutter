import 'package:json_annotation/json_annotation.dart';

part 'order_detail.g.dart';

@JsonSerializable()
class OrderDetail extends Object {
  @JsonKey(name: 'market')
  String market;

  @JsonKey(name: 'side')
  String side;

  @JsonKey(name: 'oid')
  String oid;

  @JsonKey(name: 'price')
  String price;

  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'turnover')
  String turnover;

  @JsonKey(name: 'time')
  String time;

  @JsonKey(name: 'fee')
  String fee;

  OrderDetail(
    this.market,
    this.side,
    this.oid,
    this.price,
    this.amount,
    this.turnover,
    this.time,
    this.fee,
  );

  factory OrderDetail.fromJson(Map<String, dynamic> srcJson) =>
      _$OrderDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$OrderDetailToJson(this);
}
