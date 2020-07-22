import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/api/market_http_core.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:titan/src/widget/load_data_widget.dart';
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

  bool _showLoading = true;
  bool _isShowMore = false;
  bool _isShowSetting = false;
  bool _isLine = false;
  bool _isDepth = false;

  String _periodParameter = "15分钟";
  List<String> _normalPeriodList = ["15分钟", "1小时", "4小时", "1天"];
  List<String> _morePeriodList = ["分时", "1分钟", "5分钟", "30分钟", "1周", "1月"];

  String _periodParameterValue = "15min";
  List<String> _normalPeriodValueList = ["15min", "60min", "4hour", "1day"];
  List<String> _morePeriodValueList = ["分时", "1min", "5min", "30min", "1week", "1mon"];

  MainState _mainState = MainState.MA;
  bool get _isOpenMainState => _mainState != MainState.NONE;

  SecondaryState _secondaryState = SecondaryState.MACD;
  bool get _isOpenSecondaryState => _secondaryState != SecondaryState.NONE;

  TabController _detailTabController;
  int _detailCurrentIndex = 0;

  TabController _periodTabController;
  int _periodCurrentIndex = 0;

  List<ExcDetailEntity> buyChartList = [];
  List<ExcDetailEntity> sailChartList = [];

  List<DepthEntity> _bids, _asks;

  @override
  void initState() {
    _initData();

    _initWS();

    _requestDataFromApi(_periodParameterValue);

    super.initState();
  }

  @override
  void dispose() {
    socketChannel.sink.close();
    print('[WS]  closed');
    super.dispose();
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
                    children: ['190.83', '1', '190.83', '1', '321412']
                        .map((text) => text == '1'
                            ? SizedBox(
                                height: 6,
                              )
                            : Text(
                                text,
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: HexColor("#333333")),
                              ))
                        .toList()),
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
    double kLineHeight = 340;
    print("_bids is empty:${_bids?.isEmpty??true}");

    return SliverToBoxAdapter(
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: kLineHeight,
            color: Colors.white,
            child: KChartWidget(
              _kChartItemList,
              isLine: _isLine,
            ),
          ),
          Visibility(
            visible: _isDepth,
            child: Container(
              width: double.infinity,
              height: kLineHeight,
              color: Colors.white,
              child: DepthChart(_bids, _asks),
            ),
          ),
          Visibility(
            visible: _isShowMore,
            child: Container(
              //duration: Duration(milliseconds: 333),
              margin: EdgeInsets.only(left: 14, top: 3, right: 14),
              width: double.infinity,
              //height: _isShowMore ? 32 : 0,
              decoration: BoxDecoration(
                color: HexColor("#F5F5F5"),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _morePeriodList
                    .map((title) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _periodTextWidget(title),
                        ))
                    .toList(),
              ),
            ),
          ),
          Visibility(
            visible: _isShowSetting,
            child: Container(
              //duration: Duration(milliseconds: 333),
              margin: EdgeInsets.only(left: 14, top: 3, right: 14),
              width: double.infinity,
              //height: _isShowSetting ? 98 : 0,
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
                      _spacerWidget,
                      _textWidget(
                        "MA",
                        true,
                      ),
                      _spacerWidget,
                      _textWidget(
                        "BOLL",
                        true,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Image.asset(
                          'res/drawable/k_line_eye_${_isOpenMainState ? "open" : "close"}.png',
                          width: 16,
                          height: 11,
                        ),
                        onPressed: () {
                          if (_isOpenMainState) {
                            setState(() {
                              _mainState = MainState.NONE;
                            });
                          }
                        },
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
                      _spacerWidget,
                      _textWidget(
                        "MACD",
                        false,
                      ),
                      _spacerWidget,
                      _textWidget(
                        "KDJ",
                        false,
                      ),
                      _spacerWidget,
                      _textWidget(
                        "RSI",
                        false,
                      ),
                      _spacerWidget,
                      _textWidget(
                        "WR",
                        false,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Image.asset(
                          'res/drawable/k_line_eye_${_isOpenSecondaryState ? "open" : "close"}.png',
                          width: 16,
                          height: 11,
                        ),
                        onPressed: () {
                          if (_isOpenSecondaryState) {
                            setState(() {
                              _secondaryState = SecondaryState.NONE;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _showLoading,
            child: Container(
                width: double.infinity, height: kLineHeight, alignment: Alignment.center, child: CircularProgressIndicator()),
          ),

        ],
      ),
    );
  }

  Widget get _spacerWidget => SizedBox(
        width: 30,
      );

  // MainState
  MainState enumMainStateFromString(String fruit) {
    fruit = 'MainState.$fruit';
    return MainState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
  }

  // SecondaryState
  SecondaryState enumSecondaryStateFromString(String fruit) {
    fruit = 'SecondaryState.$fruit';
    return SecondaryState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
  }

  Widget _textWidget(String title, bool isMain) {

    var isSelected = false;
    if (isMain) {
      isSelected = enumMainStateFromString(title) == _mainState;
    } else {
      isSelected = enumSecondaryStateFromString(title) == _secondaryState;
    }

    return InkWell(
      onTap: () {
        setState(() {
          if (isMain) {
            _mainState = enumMainStateFromString(title);
          } else {
            _secondaryState = enumSecondaryStateFromString(title);
          }
        });
      },
      child: Text(
        title,
        style: TextStyle(color: isSelected ? HexColor("#228BA1") : HexColor("#999999"), fontSize: 12),
      ),
    );
  }

  Widget _periodTextWidget(String title) {
    var equalValue = _periodParameter;
    return InkWell(
      onTap: () {
        _isShowMore = false;
        _periodParameter = title;

        var index = _morePeriodList.indexOf(title);
        if (index != 0) {
          _periodParameterValue = _morePeriodValueList[index];
          _requestDataFromApi(_periodParameterValue);
          _subscribeKLineDataFromWS(_periodParameterValue);
          _isLine = false;
        } else {
          _isLine = true;
        }

        setState(() {

        });
      },
      child: Text(
        title,
        style: TextStyle(color: title == equalValue ? HexColor("#228BA1") : HexColor("#999999"), fontSize: 12),
      ),
    );
  }

  Widget _periodTabWidget() {
    List<Widget> tabs = [];
    var iterable = _normalPeriodList
        .map((title) => Tab(
              child: Text(
                title,
                style: TextStyle(),
              ),
            ))
        .toList();
    tabs.addAll(iterable);

    iterable = [
      Tab(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              _periodParameter.isNotEmpty && _morePeriodList.contains(_periodParameter) ? _periodParameter : '更多',
              //style: TextStyle(color: HexColor("#333333")),
            ),
            Image.asset(
              'res/drawable/k_line_down_arrow.png',
              width: 5,
              height: 5,
              color: _periodCurrentIndex == 4 ? HexColor("#228BA1") : HexColor("#999999"),
            ),
          ],
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
          icon: Image.asset(
            'res/drawable/k_line_setting.png',
            width: 15,
            height: 13,
            color: _isShowSetting ? HexColor("#228BA1") : HexColor("#333333"),
          ),
          onPressed: () {
            _isShowMore = false;
            _isShowSetting = !_isShowSetting;
            setState(() {});
          },
        ),
      ),
    ];
    tabs.addAll(iterable);

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
          if (index == 4 && !_isShowMore) {
            _isShowMore = true;
          } else {
            _isShowMore = false;
          }
          _isShowSetting = false;

          _isLine = false;

          _periodCurrentIndex = index;

          if (index < _normalPeriodList.length) {

            _periodParameter = _normalPeriodList[index];
            _periodParameterValue = _normalPeriodValueList[index];
            _requestDataFromApi(_periodParameterValue);
            _subscribeKLineDataFromWS(_periodParameterValue);
          }

          _isDepth = (index == 5);

          setState(() {});

        },
        tabs: tabs,
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
            child: _delegationListView(),
          ),
          Visibility(
            visible: _detailCurrentIndex == 1,
            child: _transactionListView(),
          ),
        ],
      ),
    );
  }

  Widget _delegationListView() {
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

  Widget _transactionListView() {
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

  _initData() {
    // todo: test_jison_0722
    // buy
    buyChartList.add(ExcDetailEntity(2, 6, 4));
    buyChartList.add(ExcDetailEntity(2, 6, 4));
    buyChartList.add(ExcDetailEntity(2, 5, 5));
    buyChartList.add(ExcDetailEntity(2, 4, 6));
    buyChartList.add(ExcDetailEntity(2, 3, 7));
    for (int i = 0; i < 10; i++) {
      buyChartList.add(ExcDetailEntity(2, 0, 10));
    }

    // sail
    sailChartList.add(ExcDetailEntity(4, 4, 6));
    sailChartList.add(ExcDetailEntity(4, 4, 6));
    sailChartList.add(ExcDetailEntity(4, 5, 5));
    sailChartList.add(ExcDetailEntity(4, 6, 4));
    sailChartList.add(ExcDetailEntity(4, 7, 3));
    for (int i = 0; i < 10; i++) {
      sailChartList.add(ExcDetailEntity(4, 10, 0));
    }

    _detailTabController = TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );

    _periodTabController = TabController(
      initialIndex: 0,
      vsync: this,
      length: 7,
    );

    initDepthData();

  }

  initDepthData() async {
    await rootBundle.loadString('res/kline/depth.json').then((result) {
      print("[result] result:$result");

      final parseJson = json.decode(result);
      Map tick = parseJson['tick'];
      var bids = tick['bids'].map((item) => DepthEntity(item[0], item[1])).toList().cast<DepthEntity>();
      var asks = tick['asks'].map((item) => DepthEntity(item[0], item[1])).toList().cast<DepthEntity>();
      initDepth(bids, asks);
    });
  }


  void initDepth(List<DepthEntity> bids, List<DepthEntity> asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = List();
    _asks = List();
    double amount = 0.0;
    bids?.sort((left, right) => left.price.compareTo(right.price));
    //倒序循环 //累加买入委托量
    bids.reversed.forEach((item) {
      amount += item.amount;
      item.amount = amount;
      _bids.insert(0, item);
    });

    amount = 0.0;
    asks?.sort((left, right) => left.price.compareTo(right.price));
    //循环 //累加买入委托量
    asks?.forEach((item) {
      amount += item.amount;
      item.amount = amount;
      _asks.add(item);
    });

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

    _subscribeKLineDataFromWS(_periodParameterValue);
  }

  void _requestDataFromApi(String period, {bool isReplace}) async {
    _showLoading = true;
    setState(() {});

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
      _showLoading = false;
      setState(() {});
    }
  }

  void _addKChartDataFromWS(Map<String, dynamic> data) async {
    KLineEntity latestKLineItem;
    try {
      latestKLineItem = KLineEntity.fromJson(data['tick']);
      print(latestKLineItem.toString());
      if (latestKLineItem.id != _kChartItemList.last.id) {
        //Fluttertoast.showToast(msg: 'Add Data ${latestKLineItem.id} ');

        _kChartItemList.add(latestKLineItem);
        KLineUtil.calculate(_kChartItemList);

        _showLoading = false;
      } else {
        //Fluttertoast.showToast(msg: 'Update Data ${latestKLineItem.id} ');

        _kChartItemList.last = latestKLineItem;
        KLineUtil.calculate(_kChartItemList);

        _showLoading = false;
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
