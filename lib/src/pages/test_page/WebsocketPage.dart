import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketTestPage extends StatefulWidget {
  @override
  _WebSocketTestPageState createState() => _WebSocketTestPageState();
}

class _WebSocketTestPageState extends State<WebSocketTestPage> {
  TextEditingController _controller = TextEditingController();
  String _wsValidData = '';

  ///test using huobi's ws
  WebSocketChannel channel =
      IOWebSocketChannel.connect('wss://api.huobi.pro/ws');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _subscribeKLine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket测试'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Send message'),
                ),
              ),
              RaisedButton(
                child: Text('Subscribe KLine'),
                onPressed: () {
                  _subscribeKLine();
                },
              ),
              StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    try {
                      var decompressedData = utf8.decode(
                        GZipCodec().decode(snapshot.data),
                        allowMalformed: true,
                      );
                      print(decompressedData);
                      Map<String, dynamic> data = json.decode(decompressedData);
                      if (data['ping'] != null) {
                        _respondHeartBeat(data['ping']);
                      } else {
                        _wsValidData = decompressedData;
                      }
                    } catch (e) {
                      print(e.toString());
                    }
                  } else {
                    print('[StreamBuilder] called but no snapshot.data');
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(_wsValidData),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text);
    }
  }

  ///respond heartbeat[ping-pong]
  void _respondHeartBeat(dynamic ping) {
    Map<String, dynamic> pong = Map<String, dynamic>();
    pong['pong'] = ping;
    channel.sink.add(json.encode(pong));
  }

  void _subscribeKLine() {
    Map<String, dynamic> requestKLine = Map<String, dynamic>();
    requestKLine['sub'] = 'market.btcusdt.kline.1min';
    requestKLine['id'] = 'hyn_client';

    channel.sink.add(json.encode(requestKLine));
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
