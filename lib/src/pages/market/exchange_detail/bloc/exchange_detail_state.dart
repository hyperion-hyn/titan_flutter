part of 'exchange_detail_bloc.dart';

abstract class ExchangeDetailState extends AllPageState {
}

class ExchangeInitial extends ExchangeDetailState {
  @override
  List<Object> get props => [];
}

class ExchangeMarketInfoState extends ExchangeDetailState {
  final MarketInfoEntity marketInfoEntity;
  ExchangeMarketInfoState(this.marketInfoEntity);
}