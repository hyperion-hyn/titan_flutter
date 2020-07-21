import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/api/market_http_core.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:web_socket_channel/io.dart';

import '../../../../env.dart';

class KLineDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KLineDetailPageState();
  }
}

class _KLineDetailPageState extends State<KLineDetailPage> with TickerProviderStateMixin {
  final IOWebSocketChannel socketChannel = IOWebSocketChannel.connect(
    'wss://api.huobi.pro/ws',
  );
  List<KLineEntity> _kChartItemList;
  bool showLoading = true;

  TabController _detailTabController;
  TabController _periodTabController;

  int _detailCurrentIndex = 0;
  int _periodCurrentIndex = 0;

  List<ExcDetailEntity> buyChartList = [];
  List<ExcDetailEntity> sailChartList = [];

  bool _isShowMore = false;
  bool _isShowSetting = false;

  @override
  void initState() {
    buyChartList.add(ExcDetailEntity(2, 6, 4));
    buyChartList.add(ExcDetailEntity(2, 6, 4));
    buyChartList.add(ExcDetailEntity(2, 5, 5));
    buyChartList.add(ExcDetailEntity(2, 4, 6));
    buyChartList.add(ExcDetailEntity(2, 3, 7));
    for (int i = 0; i < 10; i++) {
      buyChartList.add(ExcDetailEntity(2, 0, 10));
    }

    sailChartList.add(ExcDetailEntity(4, 4, 6));
    sailChartList.add(ExcDetailEntity(4, 4, 6));
    sailChartList.add(ExcDetailEntity(4, 5, 5));
    sailChartList.add(ExcDetailEntity(4, 6, 4));
    sailChartList.add(ExcDetailEntity(4, 7, 3));
    for (int i = 0; i < 10; i++) {
      sailChartList.add(ExcDetailEntity(4, 10, 0));
    }
    _detailTabController = new TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );

    _periodTabController = new TabController(
      initialIndex: 0,
      vsync: this,
      length: 7,
    );

    _initWS();

    _requestDataFromApi('1min');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: CustomScrollView(slivers: <Widget>[
            _headerWidget(),
            _dividerWidget(),
            _periodTabWidget(),
            _dividerWidget(height: 0.5),
            _kLineWidget(),
            _dividerWidget(),
            _detailTabWidget(),
            _detailWidget(),
          ]),
        ),
      ),
    );
  }

  Widget _appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        color: Colors.white,
        child: SafeArea(
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
              //Icon(Icons.format_align_center),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
//              'HYN/${widget.symbol}',
                  'HYN/USDT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Spacer(),
//                Padding(
//                  padding: EdgeInsets.all(8.0),
//                  child: Icon(Icons.share),
//                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerWidget() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
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

  Widget _dividerWidget({double height = 5}) {
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor("#F5F5F5"),
        height: height,
      ),
    );
  }

  Widget _kLineWidget() {
    return SliverToBoxAdapter(
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 340,
//        color: Colors.amber,
            color: Colors.white,
            child: KChartWidget(
              _kChartItemList,
              isLine: false,
            ),
          ),
          Visibility(
            visible: _isShowMore,
            child: Container(
              margin: const EdgeInsets.only(left: 14, top: 3, right: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: HexColor("#F5F5F5"),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ["分时", "1分钟", "5分钟", "30分钟", "1周", "1月"]
                    .map((e) => InkWell(
                  onTap: (){
                    setState(() {
                      _isShowMore = false;
                    });
                  },
                      child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              e,
                              style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                            ),
                          ),
                    ))
                    .toList(),
              ),
            ),
          ),
          Visibility(
            visible: _isShowSetting,
            child: Container(
              margin: const EdgeInsets.only(left: 14, top: 3, right: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: HexColor("#F5F5F5"),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Text(
                          "主图",
                          style: TextStyle(color: HexColor("#333333"), fontSize: 12),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "MA",
                        style: TextStyle(color: HexColor("#228BA1"), fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        "BOLL",
                        style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.lock,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      height: 0.5,
                      color: HexColor("#DEDEDE"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Text(
                          "副图",
                          style: TextStyle(color: HexColor("#333333"), fontSize: 12),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "MACD",
                        style: TextStyle(color: HexColor("#228BA1"), fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        "KDJ",
                        style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        "RSI",
                        style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        "WR",
                        style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.lock,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      height: 0.5,
                      color: HexColor("#DEDEDE"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14, top: 12, bottom: 12),
                        child: Text(
                          "指标设置",
                          style: TextStyle(color: HexColor("#333333"), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodTabWidget() {
    return SliverToBoxAdapter(
      child: TabBar(
        controller: _periodTabController,
        isScrollable: true,
        labelColor: HexColor('#228BA1'),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: HexColor('#228BA1'),
        indicatorWeight: 2,
        indicatorPadding: EdgeInsets.only(bottom: 2),
        unselectedLabelColor: HexColor("#999999"),
        onTap: (int index) {
          setState(() {
            if (index == 4 && !_isShowMore) {
              _isShowMore = true;
            } else {
              _isShowMore = false;
            }
            _isShowSetting = false;

            _periodCurrentIndex = index;
          });
        },
        tabs: [
          Tab(
            child: Text(
              "15分钟",
              style: TextStyle(),
            ),
          ),
          Tab(
            child: Text(
              '1小时',
              style: TextStyle(),
            ),
          ),
          Tab(
            child: Text(
              '4小时',
              style: TextStyle(),
            ),
          ),
          Tab(
            child: Text(
              '1天',
              style: TextStyle(),
            ),
          ),
          Tab(
            child: Text(
              '更多',
              style: TextStyle(color: HexColor("#333333")),
            ),
          ),
          Tab(
            child: Text(
              '深度图',
              style: TextStyle(),
            ),
          ),
          Tab(
            child: IconButton(
              icon: Icon(
                Icons.more,
              ),
              onPressed: () {
                _isShowMore = false;
                _isShowSetting = !_isShowSetting;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTabWidget() {
    return SliverToBoxAdapter(
      child: TabBar(
        controller: _detailTabController,
        isScrollable: true,
        labelColor: HexColor('#228BA1'),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: HexColor('#228BA1'),
        indicatorWeight: 2,
        indicatorPadding: EdgeInsets.only(bottom: 2),
        unselectedLabelColor: HexColor("#999999"),
        onTap: (int index) {
          setState(() {
            _detailCurrentIndex = index;
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

  Widget _detailWidget() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Visibility(
            visible: _detailCurrentIndex == 0,
            child: _depthChart(),
          ),
          Visibility(
            visible: _detailCurrentIndex == 1,
            child: _exchangeChart(),
          ),
        ],
      ),
    );
  }

  Widget _depthChart() {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
      color: Colors.white,
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            ExcDetailEntity buyEntity = buyChartList[index];
            ExcDetailEntity sailEntity = sailChartList[index];

            return index == 0
                ? Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "买盘 数量(HYN)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: HexColor("#777777"),
                          ),
                        ),
                        Text(
                          "价格(USDT)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: HexColor("#777777"),
                          ),
                        ),
                        Text(
                          "数量(HYN)卖盘",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: HexColor("#777777"),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: buyEntity.leftPercent,
                                    child: Container(
                                      height: 25,
                                      color: HexColor("#ffffff"),
                                    ),
                                  ),
                                  Expanded(
                                    flex: buyEntity.rightPercent,
                                    child: Container(
                                      height: 25,
                                      color: HexColor("#EBF8F2"),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 25,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "$index",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: HexColor("#999999"),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 25,
                                    padding: EdgeInsets.only(left: index >= 9 ? 3 : 8),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "1.43543",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: HexColor("#333333"),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 25,
                                      padding: const EdgeInsets.only(right: 5),
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "180.39",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: HexColor("#53AE86"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: sailEntity.leftPercent,
                                    child: Container(
                                      height: 25,
                                      color: HexColor("#F9EFEF"),
                                    ),
                                  ),
                                  Expanded(
                                    flex: sailEntity.rightPercent,
                                    child: Container(
                                      height: 25,
                                      color: HexColor("#ffffff"),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 25,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "180.39",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: HexColor("#CC5858"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 25,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "1.43543",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: HexColor("#333333"),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 25,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(left: index >= 9 ? 3 : 8),
                                    child: Text(
                                      "$index",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: HexColor("#999999"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ],
                  );
          },
          itemCount: buyChartList.length),
    );
  }

  Widget _exchangeChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            ExcDetailEntity excDetailEntity = buyChartList[index];
            return index == 0
                ? Padding(
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
                  )
                : Padding(
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
                          child: Text(
                            excDetailEntity.viewType == 2 ? "卖出" : "买入",
                            style: TextStyle(
                                color: HexColor(excDetailEntity.viewType == 2 ? "#CC5858" : "#53AE86"),
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
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
          itemCount: buyChartList.length),
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
