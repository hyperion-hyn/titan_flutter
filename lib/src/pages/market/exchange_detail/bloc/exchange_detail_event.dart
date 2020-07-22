part of 'exchange_detail_bloc.dart';

abstract class ExchangeDetailEvent {
}

class LimitExchangeEvent extends ExchangeDetailEvent{
  String selectCoin;
  int exchangeType;
  double price;
  double amount;
  LimitExchangeEvent(this.selectCoin,this.exchangeType,this.price,this.amount);
}

class MarketExchangeEvent extends ExchangeDetailEvent{
  String selectCoin;
  int exchangeType;
  double amount;
  MarketExchangeEvent(this.selectCoin,this.exchangeType,this.amount);
}