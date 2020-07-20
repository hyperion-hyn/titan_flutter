import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:web_socket_channel/io.dart';
import '../socket_util.dart';
import './bloc.dart';

//https://cloudapidoc.github.io/API_Docs/v1/ws/#websocket-api

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  @override
  SocketState get initialState => InitialSocketState();

  final IOWebSocketChannel socketChannel;
  SocketBloc({this.socketChannel});

  @override
  Stream<SocketState> mapEventToState(
    SocketEvent event,
  ) async* {
    if (event is SubChannelEvent) {
      _subChannelRequestAction(event.channel);

      yield SubChannelState(period: event.channel);
    } else if (event is UnSubChannelEvent) {
      _unSubChannelRequestAction(event.channel);

      yield UnSubChannelState(period: event.channel);
    } else if (event is ReceivedDataEvent) {
      var receivedData = event.data;
      try {
        var decompressedData = utf8.decode(
          GZipCodec().decode(receivedData),
          allowMalformed: true,
        );

        Map<String, dynamic> data = json.decode(decompressedData);
        print("[SocketBloc] mapEventToState, response:$data");

        if (data["ping"] != null) {
          _heartPongRequestAction(data["ping"]);
        } else {
          var status = data["status"];

          var event = data["event"];

          if (status == 0) {
            var channel = data["channel"];

            if (event == SocketUtil.sub) {
              var response = data["data"];
              if (response != null) {
                yield ReceivedDataSuccessState(response: response);
              } else {
                if (channel != null) {
                  yield SubChannelSuccessState(response: event.data);
                }
              }
            } else if (event == SocketUtil.unSub) {
              if (channel != null) {
                yield UnSubChannelSuccessState(response: event.data);
              }
            }
          } else {
            var errMsg = data["err-msg"];
            var errCode = data["err-code"];

            if (event == SocketUtil.sub) {
              yield SubChannelFailState();
            } else if (event == SocketUtil.unSub) {
              yield UnSubChannelFailState();
            }
            print("[SocketBloc] mapEventToState, errMsg:$errMsg, errCode:$errCode");

            yield ReceivedDataFailState();
          }
        }
      } catch (e) {
        print(e.toString());
        yield ReceivedDataFailState();
      }
    }
  }

  ///respond heartbeat[ping-pong]
  void _heartPongRequestAction(dynamic ping) {
    print('[WS] heart，心跳正常。。。。。');

    Map<String, dynamic> pong = Map<String, dynamic>();
    pong['pong'] = ping;
    socketChannel.sink.add(json.encode(pong));
  }

  void _subChannelRequestAction(String channel) {
    print('[WS] sub，正式发起订阅, channel:$channel');

    Map<String, dynamic> params = Map<String, dynamic>();
    params['channel'] = channel;
    params['event'] = SocketUtil.sub;

    socketChannel.sink.add(json.encode(params));
  }

  void _unSubChannelRequestAction(String channel) {
    print('[WS] unSub，正式取消订阅, period:$channel');

    Map<String, dynamic> params = Map<String, dynamic>();
    params['channel'] = channel;
    params['event'] = SocketUtil.unSub;

    socketChannel.sink.add(json.encode(params));
  }
}
