import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order extends Object {
  @JsonKey(name: 'market')
  String market;

  @JsonKey(name: 'order_id')
  String orderId;

  @JsonKey(name: 'side')
  String side;

  @JsonKey(name: 'price')
  String price;

  @JsonKey(name: 'amount')
  String amount;

  @JsonKey(name: 'ctime')
  String ctime;

  @JsonKey(name: 'status')
  String status;//-1 撤销中

  @JsonKey(name: 'amount_deal')
  String amountDeal;

  @JsonKey(name: 'amount_no_deal')
  String amountNoDeal;

  Order(
    this.market,
    this.orderId,
    this.side,
    this.price,
    this.amount,
    this.ctime,
    this.status,
    this.amountDeal,
    this.amountNoDeal,
  );

  factory Order.fromJson(Map<String, dynamic> srcJson) =>
      _$OrderFromJson(srcJson);

  Order.fromSocket(List<dynamic> orderItem) {
    this.ctime = orderItem[0].toString();
    this.orderId = orderItem[1];
    this.status = orderItem[2].toString();
    this.amount = orderItem[3];
    this.amountNoDeal = orderItem[4];
    this.amountDeal =
        (Decimal.parse(amount) - Decimal.parse(amountNoDeal)).toString();
    this.price = orderItem[5];
    this.side = orderItem[6];
  }

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

class ExchangeType {
  static const BUY = 1;
  static const SELL = 2;
}

class OrderState {
  static const processing = 0;
  static const completed = 1;
  static const cancelled = 2;
}
