part of 'exchange_detail_bloc.dart';

abstract class ExchangeDetailEvent {
}

class MarketInfoEvent extends ExchangeDetailEvent{
  String marketCoin;
  MarketInfoEvent(this.marketCoin);
}

class DepthInfoEvent extends ExchangeDetailEvent{
  String symbol;
  int precision;
  DepthInfoEvent(this.symbol,this.precision);
}

class LimitExchangeEvent extends ExchangeDetailEvent{
  String marketCoin;
  int exchangeType;
  String price;
  String amount;
  LimitExchangeEvent(this.marketCoin,this.exchangeType,this.price,this.amount);
}

class MarketExchangeEvent extends ExchangeDetailEvent{
  String marketCoin;
  int exchangeType;
  String amount;
  MarketExchangeEvent(this.marketCoin,this.exchangeType,this.amount);
}