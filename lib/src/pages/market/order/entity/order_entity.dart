import 'package:json_annotation/json_annotation.dart';

part 'order_entity.g.dart';

@JsonSerializable()
class OrderEntity {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'type')
  int type;
  @JsonKey(name: 'state')
  int state;
  @JsonKey(name: 'date')
  String date;
  @JsonKey(name: 'symbol')
  String symbol;
  @JsonKey(name: 'price')
  double price;
  @JsonKey(name: 'total')
  double total;
  @JsonKey(name: 'amount')
  double amount;
  @JsonKey(name: 'excuted')
  double executed;

  OrderEntity();

  OrderEntity.fromJson(dynamic json) {
  }

  OrderEntity.fromSocketJson(List<dynamic> orderItem) {
    this.date = orderItem[0].toString();
    this.id = orderItem[1].toString();
    this.state = orderItem[2];
    this.total = double.parse(orderItem[3]);
    this.amount = this.total - double.parse(orderItem[4]);
    this.price = double.parse(orderItem[5]);
    this.type = int.parse(orderItem[6]);
  }
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
