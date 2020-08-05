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

class OrderPutLimitState extends ExchangeDetailState {
  final int respCode;
  final String respMsg;
  OrderPutLimitState(this.respCode,this.respMsg);
}

class DepthInfoState extends ExchangeDetailState{
  final dynamic depthData;
  DepthInfoState(this.depthData);
}