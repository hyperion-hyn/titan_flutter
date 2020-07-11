import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/config/consts.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

import '../../../env.dart';

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
    _initWS();

    _requestDataFromApi('1min');

    super.initState();
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
                  _requestDataFromApi('1day');
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

    print('[WS]  closed');
    super.dispose();
  }

  _initWS() {
    print('[WS]  listen');

    widget.channel.stream.listen(
        (data) {
          var receivedData = data;
          try {
            var decompressedData = utf8.decode(
              GZipCodec().decode(receivedData),
              allowMalformed: true,
            );

            Map<String, dynamic> data = json.decode(decompressedData);
            if (data['ping'] != null) {
              _respondHeartBeat(data['ping']);
            } else {
              if (mounted)
                setState(() {
                  print("[WS] decompressedData:$decompressedData");
                  _wsStreamDataText = decompressedData;
                });
              _addKChartDataFromWS(data);
            }
          } catch (e) {
            print(e.toString());
          }
        },
        onDone: () => print('[WS] Done!'),
        //onDone: _reconnectWS,
        onError: (e) {
          print(e);
        });

    _subscribeKLineDataFromWS('1min');
  }

  /*
  _reconnectWS() {
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _initWS();
    });
  }*/

  void _requestDataFromApi(String period, {bool isReplace}) async {
    dynamic result;
    try {
      result = await getDataFromApi('$period');
    } catch (e) {
      print('获取数据失败');
    } finally {
      print('[WS] _requestDataFromApi, result：$result');

      // ignore: control_flow_in_finally
      if (result == null) return;

      Map parseJson = result;
      print('[WS] parseJson: ${parseJson.toString()}');
      List list = parseJson['data'];
      _kChartItemList = list.map((item) => KLineEntity.fromJson(item)).toList().reversed.toList().cast<KLineEntity>();
      KLineUtil.calculate(_kChartItemList);
      print('[WS] current list length: ${_kChartItemList.length}');
      Fluttertoast.showToast(msg: 'current list length: ${_kChartItemList.length}');
      showLoading = false;
      setState(() {});
    }
  }

 /* void _addDataFromApi(String period, {bool isReplace}) async {
    dynamic result;
    KLineEntity lastItem;
    try {
      result = await getDataFromApi('$period');
    } catch (e) {
      print('获取数据失败');
    } finally {
      Map parseJson = result;
      List list = parseJson['data'];
      lastItem = list.map((item) => KLineEntity.fromJson(item)).toList().reversed.toList().cast<KLineEntity>().last;
      _kChartItemList.add(lastItem);
      print(lastItem.toString());
      KLineUtil.calculate(_kChartItemList);
      showLoading = false;
      print('current list length: ${_kChartItemList.length}');
      Fluttertoast.showToast(msg: 'current list length: ${_kChartItemList.length}');
      setState(() {});
    }
  }*/

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

  Future<dynamic> getDataFromApi(String period) async {
    //huobi api, https://api.huobi.br.com/market/history/kline?period=1min&size=300&symbol=btcusdt
    var url = 'market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    dynamic result;
    print("[WS] --> getData, url:$url");
//    var response = await http.get(url, headers:  {'accept': 'application/dns-json'}).timeout(Duration(seconds: 15));
    var response = await MarketHttpCore.instance.get(
      url,
      options: RequestOptions(contentType: "application/json"),
    );

    print("[WS] --> getData, data:${response["data"] is List}");

    if (response["status"] == "ok") {
      result = response;
    } else {
      return "";
      //return Future.error("获取失败");
    }
    print("[WS] --> getData, result:$result");

    return result;
  }
}

class MarketHttpCore extends BaseHttpCore {
  factory MarketHttpCore() => _getInstance();

  MarketHttpCore._internal() : super(_dio);

  static MarketHttpCore get instance => _getInstance();
  static MarketHttpCore _instance;

  static MarketHttpCore _getInstance() {
    if (_instance == null) {
      _instance = MarketHttpCore._internal();

      // todo: test_jison_0428_close_log
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.MARKET_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
