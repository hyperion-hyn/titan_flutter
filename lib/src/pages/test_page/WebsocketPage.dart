import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/widget/kChart/entity/k_line_entity.dart';
import 'package:titan/src/widget/kChart/k_chart_widget.dart';
import 'package:titan/src/widget/kChart/utils/data_util.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class WebSocketPage extends StatefulWidget {
  final IOWebSocketChannel channel;

  WebSocketPage({
    Key key,
    @required this.channel,
  }) : super(key: key);

  @override
  _WebSocketPageState createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  TextEditingController _controller = TextEditingController();

  String _wsStreamDataText = '';
  List<KLineEntity> _kChartItemList;
  bool showLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestDataFromApi('1min');
    _initWS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocketTest'),
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
                  decoration: InputDecoration(labelText: 'Send a message'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(_wsStreamDataText),
              ),
              Container(
                width: double.infinity,
                height: 400,
                color: Colors.amber,
                child: KChartWidget(
                  _kChartItemList,
                  isLine: false,
                ),
              ),
              RaisedButton(
                child: Text('request [1day] '),
                onPressed: () {
                  _addDataFromApi('1day');
                },
              ),
              RaisedButton(
                child: Text('update [1min]'),
                onPressed: () {
                  _requestDataFromApi('1min');
                  setState(() {});
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
      widget.channel.sink.add(_controller.text);
    }
  }

  ///respond heartbeat[ping-pong]
  void _respondHeartBeat(dynamic ping) {
    Map<String, dynamic> pong = Map<String, dynamic>();
    pong['pong'] = ping;
    widget.channel.sink.add(json.encode(pong));
  }

  void _subscribeKLineDataFromWS(String period) {
    Map<String, dynamic> requestKLine = Map<String, dynamic>();
    requestKLine['sub'] = 'market.btcusdt.kline.$period';
    requestKLine['id'] = 'hyn_client';

    widget.channel.sink.add(json.encode(requestKLine));
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    print('websocket closed');
    super.dispose();
  }

  _initWS() {
    widget.channel.stream.listen(
        (data) {
          var receivedData = data;
          try {
            var decompressedData = utf8.decode(
              GZipCodec().decode(receivedData),
              allowMalformed: true,
            );
            print(decompressedData);
            Map<String, dynamic> data = json.decode(decompressedData);
            if (data['ping'] != null) {
              _respondHeartBeat(data['ping']);
            } else {
              if (mounted)
                setState(() {
                  _wsStreamDataText = decompressedData;
                });
              _addKChartDataFromWS(data);
            }
          } catch (e) {
            print(e.toString());
          }
        },
        onDone: _reconnectWS,
        onError: (e) {
          print(e);
        });

    _subscribeKLineDataFromWS('1min');
  }

  _reconnectWS() {
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _initWS();
    });
  }

  void _requestDataFromApi(String period, {bool isReplace}) async {
    String result;
    try {
      result = await getDataFromApi('$period');
    } catch (e) {
      print('获取数据失败');
    } finally {
      Map parseJson = json.decode(result);
      print('parseJson: ${parseJson.toString()}');
      List list = parseJson['data'];
      _kChartItemList = list
          .map((item) => KLineEntity.fromJson(item))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>();
      KLineUtil.calculate(_kChartItemList);
      print('current list length: ${_kChartItemList.length}');
      Fluttertoast.showToast(
          msg: 'current list length: ${_kChartItemList.length}');
      showLoading = false;
      setState(() {});
    }
  }

  void _addDataFromApi(String period, {bool isReplace}) async {
    String result;
    KLineEntity lastItem;
    try {
      result = await getDataFromApi('$period');
    } catch (e) {
      print('获取数据失败');
    } finally {
      Map parseJson = json.decode(result);
      List list = parseJson['data'];
      lastItem = list
          .map((item) => KLineEntity.fromJson(item))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>()
          .last;
      _kChartItemList.add(lastItem);
      print(lastItem.toString());
      KLineUtil.calculate(_kChartItemList);
      showLoading = false;
      print('current list length: ${_kChartItemList.length}');
      Fluttertoast.showToast(
          msg: 'current list length: ${_kChartItemList.length}');
      setState(() {});
    }
  }

  void _addKChartDataFromWS(Map<String, dynamic> data) async {
    KLineEntity latestKLineItem;
    try {
      latestKLineItem = KLineEntity.fromJson(data['tick']);
      print(latestKLineItem.toString());
      if (latestKLineItem.id != _kChartItemList.last.id) {
        Fluttertoast.showToast(msg: 'Add new Data ${latestKLineItem.id} ');
        _kChartItemList.add(latestKLineItem);
        KLineUtil.calculate(_kChartItemList);
        showLoading = false;
      } else {
        _kChartItemList.last = latestKLineItem;
        KLineUtil.calculate(_kChartItemList);
        showLoading = false;
      }
    } catch (e) {
      print('[_addKChartDataFromWS]]: 解析KEntity失败: ${e.toString()}');
    }
  }

  Future<String> getDataFromApi(String period) async {
    //huobi api
    var url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    String result;
    var response = await http.get(url).timeout(Duration(seconds: 7));
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      return Future.error("获取失败");
    }
    return result;
  }
}
