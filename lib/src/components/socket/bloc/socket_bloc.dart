import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/market_symbol_list.dart';
import 'package:titan/src/pages/market/exchange/exchange_page.dart';
import 'package:web_socket_channel/io.dart';
import '../socket_config.dart';
import './bloc.dart';

//https://cloudapidoc.github.io/API_Docs/v1/ws/#websocket-api

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  @override
  SocketState get initialState => InitialSocketState();

  IOWebSocketChannel socketChannel;
  ExchangeApi _exchangeApi = ExchangeApi();

  SocketBloc();

  void setSocketChannel(IOWebSocketChannel socketChannel){
    this.socketChannel = socketChannel;
  }

  @override
  Stream<SocketState> mapEventToState(
    SocketEvent event,
  ) async* {
    if (event is HeartEvent) {
      _heartAction();
      yield HeartState();
    } else if (event is SubChannelEvent) {
      print("channel = ${event.channel}");
      _subChannelRequestAction(event.channel);

      yield SubChannelState(period: event.channel);
    } else if (event is UnSubChannelEvent) {
      _unSubChannelRequestAction(event.channel);

      yield UnSubChannelState(period: event.channel);
    } else if (event is ReceivedDataEvent) {
      var receivedData = event.data;
      print("[SocketBloc] mapEventToState, receivedData:$receivedData");

      try {
        Map<String, dynamic> dataMap = json.decode(receivedData);
        print("[SocketBloc] mapEventToState, dataMap:$dataMap");

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
                if (channelValue == SocketConfig.channelKLine24Hour) {
                  var responseMap = response as Map;
                  var symbol = responseMap['symbol'];
                  var data = responseMap['data'];
                  /*{
                    status: 0,
                    channel: ws.market.allsymbol.kline.24hour,
                    event: sub,
                    data: {
                      data: [[1595732880000, 0.2000000000, 0.2000000000, 0.2000000000, 0.2000000000, 0.0000000000, 0.0000000000]],
                      symbol: hynusdt
                    }
                  }*/

                  print("[SocketBloc] mapEventToState, channelValue:$channelValue， symbol:$symbol, data:$data");

                  yield ChannelKLine24HourState(symbol:symbol,response: data);
                } else if (channelValue.contains("depth")) {
                  yield ChannelExchangeDepthState(response: response);
                } else if (channelValue.contains("trade.detail")) {
                  yield ChannelExchangeDepthState(response: response);
                } else if (channelValue.startsWith("user") &&
                    channelValue.contains("tick")) {
                  yield ChannelUserTickState(response: response);
                } else {
                  yield ChannelKLinePeriodState(
                      channel: channelValue, response: response);
                }
              }
              yield ReceivedDataSuccessState(response: dataMap);
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
        } else if (status == 200) {
          if (errMsg != null) {
            print("[SocketBloc] 接收心跳,正常");

            yield HeartSuccessState();
          }
        } else {
          print(
              "[SocketBloc] mapEventToState, errMsg:$errMsg, errCode:$errCode");

          if (eventAction == SocketConfig.sub) {
            yield SubChannelFailState();
          } else if (eventAction == SocketConfig.unSub) {
            yield UnSubChannelFailState();
          }
        }
      } catch (e) {
        print("[SocketBloc] e:$e");
        yield ReceivedDataFailState();
      }
    }else if(event is MarketSymbolEvent){
      var response = await _exchangeApi.getMarketAllSymbol();
      MarketSymbolList marketSymbolList = MarketSymbolList.fromJson(response);
      var _marketItemList = List<MarketItemEntity>();
      if (marketSymbolList.hynusdt != null) {
        _marketItemList.add(MarketItemEntity(
          'hynusdt',
          marketSymbolList.hynusdt,
          symbolName: 'USDT',
        ));
      }
      if (marketSymbolList.hyneth != null) {
        _marketItemList.add(MarketItemEntity(
          'hyneth',
          marketSymbolList.hyneth,
          symbolName: 'ETH',
        ));
      }
      yield MarketSymbolState(_marketItemList);
    }
  }

  void _heartAction() {
    print('[WS] heart，发送心跳, date:${DateTime.now()}');

    var pong = "heart time fired!";
    socketChannel.sink.add(json.encode(pong));
  }

  void _subChannelRequestAction(String channel) {
    print('[WS] sub，正式发起订阅, channel:$channel');

    Map<String, dynamic> params = Map<String, dynamic>();
    params['channel'] = channel;
    params['event'] = SocketConfig.sub;
    params['cid'] = SocketConfig.cid;

    socketChannel.sink.add(json.encode(params));
  }

  void _unSubChannelRequestAction(String channel) {
    print('[WS] unSub，正式取消订阅, period:$channel');

    Map<String, dynamic> params = Map<String, dynamic>();
    params['channel'] = channel;
    params['event'] = SocketConfig.unSub;
    params['cid'] = SocketConfig.cid;

    socketChannel.sink.add(json.encode(params));
  }
}
