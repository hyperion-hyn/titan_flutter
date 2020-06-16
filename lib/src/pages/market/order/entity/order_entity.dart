class OrderEntity {
  int type;
}

class ExchangeType {
  static const BUY = 0;
  static const SELL = 1;
}

class OrderState {
  static const processing = 0;
  static const completed = 1;
  static const cancelled = 2;
}
