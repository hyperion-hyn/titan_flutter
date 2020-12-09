import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/pages/market/entity/market_symbol_list.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:web_socket_channel/io.dart';
import 'package:rxdart/rxdart.dart';
import '../socket_config.dart';
import './bloc.dart';

//https://cloudapidoc.github.io/API_Docs/v1/ws/#websocket-api

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  @override
  SocketState get initialState => InitialSocketState();

  IOWebSocketChannel socketChannel;
  ExchangeApi _exchangeApi = ExchangeApi();

  SocketBloc();

  void setSocketChannel(IOWebSocketChannel socketChannel) {
    this.socketChannel = socketChannel;
  }

  // @override
  // Stream<Transition<SocketEvent, SocketState>> transformEvents(Stream<SocketEvent> events, transitionFn) {
  //   return events.debounceTime(const Duration(milliseconds: 100)).asyncExpand(transitionFn);
  // }

  @override
  Stream<SocketState> mapEventToState(
    SocketEvent event,
  ) async* {
    if (event is HeartEvent) {
      _heartAction();
      yield HeartState();
    } else if (event is SubChannelEvent) {
      LogUtil.printMessage("channel = ${event.channel}");
      _subChannelRequestAction(event.channel);

      yield SubChannelState(channel: event.channel);
    } else if (event is UnSubChannelEvent) {
      _unSubChannelRequestAction(event.channel);

      yield UnSubChannelState(channel: event.channel);
    } else if (event is ReceivedDataEvent) {
      var receivedData = event.data;
      // LogUtil.printMessage(
      //     "[SocketBloc] mapEventToState, receivedData:$receivedData");

      try {
        Map<String, dynamic> dataMap = json.decode(receivedData);
        //LogUtil.printMessage("[SocketBloc] mapEventToState, dataMap:$dataMap");

        var status = dataMap["status"];
        var eventAction = dataMap["event"];
        var errMsg = dataMap["err"];
        var errCode = dataMap["err-code"];
        var channel = dataMap["channel"];
        var response = dataMap["data"];

        if (status == 0) {
          if (eventAction == SocketConfig.sub) {
            if (response != null) {
              if (channel != null && channel is String) {
                String channelValue = channel;


                //LogUtil.printMessage("[SocketBloc] mapEventToState, channelValue:$channelValue");


                if (channelValue == SocketConfig.channelKLine24Hour) {

                  var responseMap = response as Map;
                  var symbol = responseMap['symbol'];
                  var data = responseMap['data'];
                  //LogUtil.printMessage("[SocketBloc] mapEventToState, channelValue:$channelValue， symbol:$symbol, data:$data");

                  /*{
                    status: 0,
                    channel: ws.market.allsymbol.kline.24hour,
                    event: sub,
                    data: {
                      data: [[
                      1595732880000,
                      0.2000000000,
                      0.2000000000,
                      0.2000000000,
                      0.2000000000,
                      0.0000000000,
                      0.0000000000]],
                      symbol: hynusdt
                    }
                  }*/


                  yield ChannelKLine24HourState(symbol: symbol, response: data);
                } else if (channelValue.contains("depth")) {
                  yield ChannelExchangeDepthState(channel: channelValue ,response: response,);
                } else if (channelValue.contains("trade.detail")) {
                  yield ChannelTradeDetailState(channel: channelValue ,response: response,);
                } else if (channelValue.startsWith("user") &&
                    channelValue.contains("tick")) {
                  yield ChannelUserTickState(channel: channelValue,response: response);
                } else {
                  yield ChannelKLinePeriodState(
                      channel: channelValue, response: response);
                }
              }
              // yield ReceivedDataSuccessState(response: dataMap);
            } else {
              if (channel != null) {
                yield SubChannelSuccessState(channel: channel);
              }
            }
          } else if (eventAction == SocketConfig.unSub) {
            if (channel != null) {
              yield UnSubChannelSuccessState(channel: channel);
            }
          }
        } else if (status == 200 || status == 500) {
          if (errMsg != null && status == 500) {
            //LogUtil.printMessage("[SocketBloc] 接收心跳,正常");

            yield HeartSuccessState();
          }
        } else {
          // LogUtil.printMessage(
          //     "[SocketBloc] mapEventToState, errMsg:$errMsg, errCode:$errCode");

          if (eventAction == SocketConfig.sub) {
            yield SubChannelFailState();
          } else if (eventAction == SocketConfig.unSub) {
            yield UnSubChannelFailState();
          }
        }
      } catch (e) {
        LogUtil.printMessage("[SocketBloc] e:$e");
        yield ReceivedDataFailState();
      }
    } else if (event is MarketSymbolEvent) {
      // 价格行情
      var response = await _exchangeApi.getMarketAllSymbol();
      List<MarketItemEntity> _marketItemList =
          MarketSymbolList.fromJsonToMarketItemList(response);

      yield MarketSymbolState(_marketItemList);
    }
  }

  void _heartAction() {
    //LogUtil.printMessage('[WS] heart，发送心跳, date:${DateTime.now()}');

    var pong = "heart time fired!";
    socketChannel.sink.add(json.encode(pong));
  }

  void _subChannelRequestAction(String channel) {
    LogUtil.printMessage('[WS] sub，正式发起订阅, channel:$channel');

    Map<String, dynamic> params = Map<String, dynamic>();
    params['channel'] = channel;
    params['event'] = SocketConfig.sub;
    params['cid'] = SocketConfig.cid;

    socketChannel.sink.add(json.encode(params));
  }

  void _unSubChannelRequestAction(String channel) {
    LogUtil.printMessage('[WS] unSub，正式取消订阅, period:$channel');

    Map<String, dynamic> params = Map<String, dynamic>();
    params['channel'] = channel;
    params['event'] = SocketConfig.unSub;
    params['cid'] = SocketConfig.cid;

    socketChannel.sink.add(json.encode(params));
  }
}
