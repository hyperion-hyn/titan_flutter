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

  final IOWebSocketChannel socketChannel = IOWebSocketChannel.connect(SocketUtil.domain);

  @override
  void initState() {
    super.initState();

    _initWS();
  }

  @override
  void dispose() {
    socketChannel.sink.close();
    print('[WS]  closed');
    super.dispose();
  }

  _initWS() {
    print('[WS]  init');

    socketChannel.stream.listen((data) {
      print('[WS]  listen, data');

      BlocProvider.of<SocketBloc>(context).add(ReceivedDataEvent(data: data));
    }, onDone: () {
      print('[WS] Done!');

      _reconnectWS();
    }, onError: (e) {
      print('[WS] Error, $e');
    });
  }

  _reconnectWS() {
    print('[WS] Reconnect!');

    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _initWS();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (ctx) => SocketBloc(socketChannel: socketChannel), child: widget.child);
  }
}
