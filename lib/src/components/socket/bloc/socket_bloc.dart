import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:web_socket_channel/io.dart';
import './bloc.dart';

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
    }
    else if (event is UnSubChannelEvent) {
      _unSubChannelRequestAction(event.channel);
      
      yield UnSubChannelState(period: event.channel);
    }
    else if (event is ReceivedDataEvent) {
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
          var id = data["id"];

          if (status == "ok") {
            var subbed = data["subbed"];

            var unSubbed = data["unsubbed"];
            if (subbed != null) {
              yield SubChannelSuccessState(response: event.data);
            }

            if (unSubbed != null) {
              yield UnSubChannelSuccessState(response: event.data);
            }

          } else {
            var errMsg = data["err-msg"];
            var errCode = data["err-code"];

            if (id == subId) {
              yield SubChannelFailState();
            }
            else if (id == unSubId) {
              yield UnSubChannelFailState();
            }
            print("[SocketBloc] mapEventToState, errMsg:$errMsg, errCode:$errCode");
          }
        }
        yield ReceivedDataState(response: data);
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

    Map<String, dynamic> requestKLine = Map<String, dynamic>();
    requestKLine['sub'] = channel;
    requestKLine['id'] = subId;

    socketChannel.sink.add(json.encode(requestKLine));
  }

  void _unSubChannelRequestAction(String channel) {
    print('[WS] unSub，正式取消订阅, period:$channel');

    Map<String, dynamic> requestKLine = Map<String, dynamic>();
    requestKLine['unsub'] = channel;
    requestKLine['id'] = unSubId;

    socketChannel.sink.add(json.encode(requestKLine));
  }
  
  final String subId = "sub_id";
  final String unSubId = "un_sub_id";

}
