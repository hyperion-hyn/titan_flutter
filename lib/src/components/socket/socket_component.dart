import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_util.dart';
import 'package:web_socket_channel/io.dart';

class SocketComponent extends StatefulWidget {
  final Widget child;

  SocketComponent({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _SocketState();
  }
}

class _SocketState extends State<SocketComponent> {
  /*final IOWebSocketChannel socketChannel = IOWebSocketChannel.connect(
    'wss://api.huobi.pro/ws',
  );*/

  IOWebSocketChannel _socketChannel;

  SocketBloc _bloc;

  @override
  void initState() {
    super.initState();

    _initWS();
    _initBloc();
  }

  @override
  void dispose() {
    print('[WS]  closed');

    _socketChannel.sink.close();
    _bloc.close();
    super.dispose();
  }

  _initWS() {
    print('[WS]  init');
    _socketChannel = IOWebSocketChannel.connect(SocketUtil.domain);

    print('[WS]  listen');
    _socketChannel.stream.listen((data) {
      print('[WS]  listen..., data');

      _bloc.add(ReceivedDataEvent(data: data));
    }, onDone: () {
      print('[WS] Done!');

      _reconnectWS();
    }, onError: (e) {
      // e is :WebSocketChannelException
      print('[WS] Error, e:$e');
    });

    // 心跳，预防一分钟没有消息，自动断开链接。
    Timer.periodic(Duration(seconds : 30), (t) {
      _bloc.add(HeartEvent());
    });
  }

  _initBloc() {
    _bloc = SocketBloc(socketChannel: _socketChannel);
  }

  _reconnectWS() {
    print('[WS] Reconnect!');

    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _initWS();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (ctx) => _bloc, child: widget.child);
  }
}
