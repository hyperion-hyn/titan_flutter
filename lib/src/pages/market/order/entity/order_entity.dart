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

  OrderEntity.fromJson(Map<String, dynamic> json) {}
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
