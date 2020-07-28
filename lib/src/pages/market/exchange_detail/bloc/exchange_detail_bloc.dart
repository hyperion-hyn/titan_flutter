import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/market_info_entity.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';

part 'exchange_detail_event.dart';
part 'exchange_detail_state.dart';

class ExchangeDetailBloc extends Bloc<ExchangeDetailEvent, ExchangeDetailState> {

  ExchangeApi exchangeApi = ExchangeApi();

  @override
  ExchangeDetailState get initialState => ExchangeInitial();

  @override
  Stream<ExchangeDetailState> mapEventToState(
      ExchangeDetailEvent event,
  ) async* {
    if (event is LimitExchangeEvent) {
      await exchangeApi.orderPutLimit(event.marketCoin, event.exchangeType, event.price, event.amount);
    } else if (event is MarketExchangeEvent) {
      await exchangeApi.orderPutMarket(event.marketCoin, event.exchangeType, event.amount);
    } else if (event is MarketInfoEvent) {
      MarketInfoEntity marketInfoEntity = await exchangeApi.getMarketInfo(event.marketCoin);
      yield ExchangeMarketInfoState(marketInfoEntity);
    } else if (event is DepthInfoEvent) {
      var depthData = await exchangeApi.historyDepth(event.symbol,precision: event.precision);
      yield DepthInfoState(depthData);
    }
  }
}
