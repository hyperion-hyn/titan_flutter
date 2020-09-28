import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:titan/src/basic/http/http_exception.dart';
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
      try {
        await exchangeApi.orderPutLimit(event.marketCoin, event.exchangeType, event.price, event.amount);
        yield OrderPutLimitState();
      }catch(error){
        if(error is HttpResponseCodeNotSuccess){
          yield OrderPutLimitState(respCode: error.code, respMsg: error.message);
        }else{
          yield OrderPutLimitState(respCode: -10000, respMsg: "网络异常");
        }
      }
    } else if (event is MarketExchangeEvent) {
      await exchangeApi.orderPutMarket(event.marketCoin, event.exchangeType, event.amount);
    } else if (event is MarketInfoEvent) {
      try {
        MarketInfoEntity marketInfoEntity = await exchangeApi.getMarketInfo(event.marketCoin);
        yield ExchangeMarketInfoState(marketInfoEntity);
      }catch(error){
        yield ExchangeMarketInfoState(null);
      }
    } else if (event is DepthInfoEvent) {
      var depthData = await exchangeApi.historyDepth(event.symbol,precision: event.precision);
      yield DepthInfoState(depthData);
    }
  }
}
