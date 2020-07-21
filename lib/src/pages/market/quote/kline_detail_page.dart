import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:titan/src/pages/market/exchange/exchange_page.dart';
import 'package:titan/src/pages/node/map3page/map3_atlas_introduction.dart';
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';
import 'package:titan/src/pages/wallet/wallet_page/wallet_page.dart';
import 'package:web_socket_channel/io.dart';

import '../../../../env.dart';

class KLineDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KLineDetailPageState();
  }
}

class _KLineDetailPageState extends State<KLineDetailPage> with SingleTickerProviderStateMixin {
  final IOWebSocketChannel socketChannel = IOWebSocketChannel.connect(
    'wss://api.huobi.pro/ws',
  );
  List<KLineEntity> _kChartItemList;
  bool showLoading = true;

  TabController _tabController;

  int currentIndex = 0;

  List<ExcDetailEntity> chartList = [];

  @override
  void initState() {
    chartList.add(ExcDetailEntity(4, 0, 10));
    chartList.add(ExcDetailEntity(4, 3, 7));
    chartList.add(ExcDetailEntity(4, 4, 6));
    chartList.add(ExcDetailEntity(4, 5, 5));
    chartList.add(ExcDetailEntity(4, 6, 4));
    chartList.add(ExcDetailEntity(2, 6, 4));
    chartList.add(ExcDetailEntity(2, 5, 5));
    chartList.add(ExcDetailEntity(2, 4, 6));
    chartList.add(ExcDetailEntity(2, 3, 7));
    chartList.add(ExcDetailEntity(2, 0, 10));

    _tabController = new TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );

    _initWS();

    _requestDataFromApi('1min');

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(slivers: <Widget>[
          _appBar(),
          _divider(),
          _kLine(),
          _divider(),
          _exchange(),
          _detail(),
        ]),
      ),
    );
  }

  Widget _appBar() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 14, 12),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Icon(Icons.format_align_center),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
//              'HYN/${widget.symbol}',
                    'HYN/USDT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.share),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 14, 7),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '190.00',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 28, color: HexColor("#53AE86")),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    RichText(
                      text: TextSpan(
                          text: "≈￥23931 ",
                          style: TextStyle(
                            color: HexColor("#777777"),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                                text: "+1.9%",
                                style: TextStyle(
                                  color: HexColor("#259D25"),
                                  fontSize: 14,
                                ))
                          ]),
                    )
                  ],
                ),
                Spacer(),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '高',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10, color: HexColor("#999999")),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '低',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10, color: HexColor("#999999")),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '24H',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10, color: HexColor("#999999")),
                      ),
                    ]),
                SizedBox(
                  width: 16,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '190.83',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: HexColor("#333333")),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        '190.83',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: HexColor("#333333")),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        '321412',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: HexColor("#333333")),
                      ),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor("#F5F5F5"),
        height: 5,
      ),
    );
  }

  Widget _kLine() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 346,
//        color: Colors.amber,
        color: Colors.white,
        child: KChartWidget(
          _kChartItemList,
          isLine: false,
        ),
      ),
    );
  }

  Widget _exchange() {
    return SliverToBoxAdapter(
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: HexColor('#228BA1'),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: HexColor('#228BA1'),
        indicatorWeight: 3,
        indicatorPadding: EdgeInsets.only(bottom: 2),
        unselectedLabelColor: HexColor("#999999"),
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        tabs: [
          Tab(
            child: Text(
              "挂单委托",
              style: TextStyle(),
            ),
          ),
          Tab(
            child: Text(
              '成交',
              style: TextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Visibility(
            visible: currentIndex == 0,
            child: _depthChart(),
          ),
          Visibility(
            visible: currentIndex == 1,
            child: _exchangeChart(),
          ),
        ],
      ),
    );
  }

  Widget _depthChart() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          ExcDetailEntity excDetailEntity = chartList[index];
          if (excDetailEntity.viewType == 2 || excDetailEntity.viewType == 4) {
            Color bgColor = excDetailEntity.viewType == 2 ? HexColor("#EBF8F2") : HexColor("#F9EFEF");
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: excDetailEntity.leftPercent,
                      child: Container(
                        height: 23,
                        color: HexColor("#ffffff"),
                      ),
                    ),
                    Expanded(
                      flex: excDetailEntity.rightPercent,
                      child: Container(
                        height: 23,
                        color: HexColor("#EBF8F2"),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "1111",
                    ),
                    Spacer(),
                    Text(
                      "1111",
                    )
                  ],
                ),
              ],
            );
          } else {
            return Text("");
          }
        },
        itemCount: chartList.length);
  }

  Widget _exchangeChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            ExcDetailEntity excDetailEntity = chartList[index];
            return index == 0?Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                        "时间",
                      style: TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "方向",
                      style: TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "价格(USDT)",
                      textAlign: TextAlign.end,
                      style: TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "数量(HYN)",
                      textAlign: TextAlign.end,
                      style: TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                ],
              ),
            ):Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                      "14:35:43",
                      style: TextStyle(color: HexColor("#333333"), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child:  Text(
                      excDetailEntity.viewType == 2?"卖出":"买入",
                      style: TextStyle(color: HexColor(excDetailEntity.viewType == 2?"#CC5858":"#53AE86"), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "181.43",
                      textAlign: TextAlign.end,
                      style: TextStyle(color: HexColor("#333333"), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "1.43543",
                      textAlign: TextAlign.end,
                      style: TextStyle(color: HexColor("#333333"), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: chartList.length),
    );
  }

  ///respond heartbeat[ping-pong]
  void _respondHeartBeat(dynamic ping) {
    Map<String, dynamic> pong = Map<String, dynamic>();
    pong['pong'] = ping;
    socketChannel.sink.add(json.encode(pong));
  }

  void _subscribeKLineDataFromWS(String period) {
    Map<String, dynamic> requestKLine = Map<String, dynamic>();
    requestKLine['sub'] = 'market.btcusdt.kline.$period';
    requestKLine['id'] = 'hyn_client';

    socketChannel.sink.add(json.encode(requestKLine));
  }

  @override
  void dispose() {
    socketChannel.sink.close();

    print('[WS]  closed');
    super.dispose();
  }

  _initWS() {
    print('[WS]  listen');

    socketChannel.stream.listen(
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
                  //print("[WS] decompressedData:$decompressedData");
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
