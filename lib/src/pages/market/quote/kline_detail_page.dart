import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:titan/src/pages/market/entity/trade_info_entity.dart';
import 'package:titan/src/utils/format_util.dart';

class KLineDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KLineDetailPageState();
  }
}

class _KLineDetailPageState extends State<KLineDetailPage> with TickerProviderStateMixin {
  final ExchangeApi api = ExchangeApi();

  List<KLineEntity> _kChartItemList = [];
  List<TradeInfoEntity> _tradeItemList = [];
  List<DepthInfoEntity> _buyDepthItemList = [];
  List<DepthInfoEntity> _sellDepthItemList = [];

  PeriodInfoEntity _periodParameter;
  String _symbol = 'hynusdt';
  KLineEntity _channel24HourKLineEntity;

  bool _showLoadingKLine = true;
  bool _showLoadingTrade = true;

  bool _isShowMore = false;
  bool _isShowSetting = false;

  bool get _isDepth => _periodTabController.index == 5;
  bool get _isLine => _periodParameter.name == _morePeriodList.first.name;

//  注：period类型有如下”：'1min', '5min', '15min', '30min', '60min', '1day', '1week'，"1mon"
  List<PeriodInfoEntity> _normalPeriodList = [
    PeriodInfoEntity(name: "15分钟", value: "15min"),
    PeriodInfoEntity(name: "1小时", value: "60min"),
    PeriodInfoEntity(name: "1天", value: "1day")
  ];

  List<PeriodInfoEntity> _morePeriodList = [
    PeriodInfoEntity(name: "分时", value: "分时"),
    PeriodInfoEntity(name: "1分钟", value: "1min"),
    PeriodInfoEntity(name: "5分钟", value: "5min"),
    PeriodInfoEntity(name: "30分钟", value: "30min"),
    PeriodInfoEntity(name: "1周", value: "1week"),
    PeriodInfoEntity(name: "1月", value: "1mon"),
  ];

  MainState _mainState = MainState.MA;
  bool get _isOpenMainState => _mainState != MainState.NONE;

  SecondaryState _secondaryState = SecondaryState.MACD;
  bool get _isOpenSecondaryState => _secondaryState != SecondaryState.NONE;

  TabController _detailTabController;
  int _detailCurrentIndex = 0;

  TabController _periodTabController;
  int _periodCurrentIndex = 0;
  int _lastSelectedIndex = 0;

  List<ExcDetailEntity> _buyChartList = [];
  List<ExcDetailEntity> _sellChartList = [];

  @override
  void initState() {
    _initData();

    _initChannel();

    _setupRequest();

    super.initState();
  }

  @override
  void dispose() {
    _unSubChannels();

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
    var _open = _channel24HourKLineEntity?.open?.toString() ?? "--";
    var _high = _channel24HourKLineEntity?.high?.toString() ?? "--";
    var _low = _channel24HourKLineEntity?.low?.toString() ?? "--";
    var _24Hour = _channel24HourKLineEntity?.amount?.toString() ?? "--";
    var _price = _channel24HourKLineEntity?.amount?.toString() ?? "-- ";
//    _price = "≈￥23931 ";
    var _percent = _channel24HourKLineEntity?.amount?.toString() ?? "--";
//    _percent = "+1.9%";

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
                      _open,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 28, color: HexColor("#53AE86")),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    RichText(
                      text: TextSpan(
                          text: _price,
                          style: TextStyle(
                            color: HexColor("#777777"),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                                text: _percent,
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
                    children: [_high, '1', _low, '1', _24Hour]
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
              mainState: _mainState,
              secondaryState: _secondaryState,
            ),
          ),
          Visibility(
            visible: _isDepth,
            child: Container(
              width: double.infinity,
              height: kLineHeight,
              color: Colors.white,
              child: DepthChart(_buyDepthItemList, _sellDepthItemList),
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
                children: _morePeriodList.map((item) => _periodTextWidget(item)).toList(),
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
                      _iconWidget(isMain: true),
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
                      _iconWidget(isMain: false),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _loadingWidget(visible: _showLoadingKLine, height: kLineHeight),
        ],
      ),
    );
  }

  Widget get _spacerWidget => SizedBox(
        width: 20,
      );

  Widget _iconWidget({bool isMain}) {
    var isOpen = isMain ? _isOpenMainState : _isOpenSecondaryState;

    return IconButton(
      icon: Container(
        //color: Colors.red,
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'res/drawable/k_line_eye_${isOpen ? "open" : "close"}.png',
          width: 16,
          height: 11,
        ),
      ),
      onPressed: () {
        if (isOpen) {
          setState(() {
            if (isMain) {
              _mainState = MainState.NONE;
            } else {
              _secondaryState = SecondaryState.NONE;
            }
          });
        }
      },
    );
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
      child: Container(
        //color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(
          title,
          style: TextStyle(color: isSelected ? HexColor("#228BA1") : HexColor("#999999"), fontSize: 12),
        ),
      ),
    );
  }

  Widget _periodTextWidget(PeriodInfoEntity item) {
    var equalValue = _periodParameter;
    return InkWell(
      onTap: () {
        _isShowMore = false;
        _periodTabController.index = 3;

        var index = _morePeriodList.indexOf(item);
        if (index != 0) {
          // old
          _unSubPeriodChannel();
          _periodParameter = item;
          _getPeriodData();
          // new
          _subPeriodChannel();
        } else {
          _periodParameter = item;
        }

        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          item.name,
          style:
              TextStyle(color: item.name == equalValue.name ? HexColor("#228BA1") : HexColor("#999999"), fontSize: 12),
        ),
      ),
    );
  }

  Widget _periodTabWidget() {
    List<Widget> tabs = [];
    var iterable = _normalPeriodList
        .map((item) => Tab(
              child: Text(
                item.name,
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
              _morePeriodList.contains(_periodParameter) ? _periodParameter.name : '更多',
              style: TextStyle(
                  color: _isShowMore || (_morePeriodList.contains(_periodParameter) && _periodCurrentIndex == 3)
                      ? HexColor("#228BA1")
                      : HexColor("#999999")),
            ),
            Image.asset(
              'res/drawable/k_line_down_arrow.png',
              width: 5,
              height: 5,
              color: _isShowMore || (_morePeriodList.contains(_periodParameter) && _periodCurrentIndex == 3)
                  ? HexColor("#228BA1")
                  : HexColor("#999999"),
            ),
          ],
        ),
      ),
      /*Tab(
        child: Text(
          '深度图',
          style: TextStyle(),
        ),
      ),*/
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
          _lastSelectedIndex = _periodTabController.previousIndex;

          if (index == 3) {
            _isShowMore = !_isShowMore;

            if (!_morePeriodList.contains(_periodParameter)) {
              _periodTabController.index = _lastSelectedIndex;
            }
          } else {
            _isShowMore = false;
          }
          _isShowSetting = false;
          _periodCurrentIndex = index;
          print("_periodCurrentIndex:$_periodCurrentIndex");

          if (index < _normalPeriodList.length) {
            // old
            _unSubPeriodChannel();
            // new
            _periodParameter = _normalPeriodList[index];
            _getPeriodData();
            _subPeriodChannel();
          }

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
            child: Stack(
              children: <Widget>[
                Visibility(visible: !_showLoadingTrade, child: delegationListView(_buyChartList, _sellChartList)),
                _loadingWidget(visible: _showLoadingTrade),
              ],
            ),
          ),
          Visibility(
            visible: _detailCurrentIndex == 1,
            child: Stack(
              children: <Widget>[
                Visibility(visible: !_showLoadingTrade, child: _transactionListView()),
                _loadingWidget(visible: _showLoadingTrade),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingWidget({bool visible = true, double height = 100}) {
    return Visibility(
      visible: visible,
      child: Container(
          width: double.infinity, height: height, alignment: Alignment.center, child: CircularProgressIndicator()),
    );
  }

  Widget _transactionListView() {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
      child: Column(
        children: <Widget>[
          Padding(
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
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                var excDetailEntity = _tradeItemList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
//                            FormatUtil.formatSecondDate(excDetailEntity.date),
                          FormatUtil.formatDate(excDetailEntity.date, isSecond: true, isMillisecond: true),
                          style: TextStyle(color: HexColor("#333333"), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          excDetailEntity.actionType == "sell" ? "卖出" : "买入",
                          style: TextStyle(
                              color: HexColor(excDetailEntity.actionType == "sell" ? "#CC5858" : "#53AE86"),
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          excDetailEntity.price,
                          textAlign: TextAlign.end,
                          style: TextStyle(color: HexColor("#333333"), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          excDetailEntity.amount,
                          textAlign: TextAlign.end,
                          style: TextStyle(color: HexColor("#333333"), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: _tradeItemList.length),
        ],
      ),
    );
  }

  _initData() {
    _periodParameter = _normalPeriodList[0];
//    _periodParameter = _normalPeriodList[1];

    _detailTabController = TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );

    _periodTabController = TabController(
      initialIndex: _periodCurrentIndex,
      vsync: this,
      length: 5,
    );
  }

  _setupRequest() {
    _getPeriodData();
    _getTradeData();
    _getDepthData();
  }

/*
  [
  1591799700000, //日期
  "9400.5900000000", //开
  "9400.5900000000", //高
  "9400.5900000000", //低
  "9400.5900000000", //收
  "256.4000000000", //额度
  "2410311.2760000000" //数量
  ]
  */
  Future _getPeriodData() async {
    setState(() {
      _showLoadingKLine = true;
    });

    var data = await api.historyKline(_symbol, period: _periodParameter.value);
    print("[WS] --> _getPeriodData, data:$data");
    _dealPeriodData(data);
  }

  _dealPeriodData(dynamic data, {bool isReplace = true, String symbol = ''}) {
    print("[WS] --> _dealPeriodData, data:${data is List}");

    if (!(data is List)) {
      return;
    }

    List dataList = data;
    List kLineDataList = dataList.map((item) {
      Map<String, dynamic> json = {};
      if (item is List) {
        List itemList = item;
        if (itemList.length >= 7) {
          json = {
            'open': double.parse(itemList[1].toString()),
            'high': double.parse(itemList[2].toString()),
            'low': double.parse(itemList[3].toString()),
            'close': double.parse(itemList[4].toString()),
            'vol': double.parse(itemList[5].toString()),
            'amount': 0,
            'count': 0,
            'id': int.parse(itemList[0].toString()) / 1000,
          };
        }
      }

      return KLineEntity.fromJson(json);
    }).toList();
//        .reversed
//        .toList()
//        .cast<KLineEntity>();
    print("[WS] --> _dealPeriodData, kLineDataList.length:${kLineDataList?.length}, symbol:$symbol");

    if (symbol.isNotEmpty) {
      if (symbol == _symbol && kLineDataList.isNotEmpty) {
        _channel24HourKLineEntity = kLineDataList.last;
      }
    } else {
      if (isReplace) {
        if (kLineDataList.isNotEmpty) {
          _kChartItemList = kLineDataList;
          KLineUtil.calculate(_kChartItemList);
        }
      } else {
        if (kLineDataList.isNotEmpty) {
          KLineUtil.addLastData(_kChartItemList, kLineDataList.last);
        }
      }
    }

    setState(() {
      _showLoadingKLine = false;
    });
  }

  /*
    [
  "1592299815201", //时间
  "9472.1800000000", //价格
  "1.10000000", //数量
  "buy" // 买
  ],
  [
  "1592299812125",
  "9472.1800000000",
  "4.10000000",
  "sell" // 卖
  ]
  * */
  Future _getTradeData() async {
    setState(() {
      _showLoadingTrade = true;
    });
    var data = await api.historyTrade(_symbol);
    print("[WS] --> _getTradeData, data:$data");

    _dealTradeData(data);
    print("[WS] --> _getTradeData, data:${data is List}");
  }

  _dealTradeData(dynamic data, {bool isReplace = true}) {
    if (!(data is List)) {
      return;
    }

    List dataList = data;
    var tradeInfoEntityList = dataList.map((item) {
      TradeInfoEntity entity = TradeInfoEntity();
      if (item is List) {
        List itemList = item;
        if (itemList.length >= 4) {
          entity.date = int.parse(itemList[0]);
          entity.price = itemList[1];
          entity.amount = itemList[2];
          entity.actionType = itemList[3];
        }
      }
      return entity;
    }).toList();
    print("[WS] --> _dealTradeData, tradeInfoEntityList.length:${tradeInfoEntityList.length}");

    if (isReplace) {
      if (tradeInfoEntityList.isNotEmpty) {
        _tradeItemList = tradeInfoEntityList;
      }
    } else {
      if (tradeInfoEntityList.isNotEmpty) {
        _tradeItemList.addAll(tradeInfoEntityList);
      }
    }

    setState(() {
      _showLoadingTrade = false;
    });
  }

/*
  "buy":[ //买盘数据[
  9448.37, //价格
  0.0538 //数量
  ] ......
  ],
  "sell":[ //卖盘数据[
  9448.37,
  0.0538
  ] ......
  ]
  */
  Future _getDepthData() async {
    var data = await api.historyDepth(_symbol);
    print("[WS] --> _getDepthData, data:$data");

    _dealDepthData(data);
    print("[WS] --> _getDepthData, data:${data is List}");
  }

  _dealDepthData(dynamic data, {bool isReplace = true}) {
    if (!(data is Map)) {
      return;
    }

    Map dataMap = data;

    List<DepthInfoEntity> deptList(dynamic cache, String actionType) {
      if (cache is List) {
        List dataList = cache;
        var depthInfoEntityList = dataList.map((item) {
          DepthInfoEntity entity = DepthInfoEntity();
          if (item is List) {
            List itemList = item;
            if (itemList.length >= 2) {
              entity.price = double.parse(itemList[0].toString());
              entity.amount = double.parse(itemList[1].toString());
              entity.actionType = actionType;
            }
          }
          return entity;
        }).toList();
        print("[WS] --> _getDepthData, depthInfoEntityList.length:${depthInfoEntityList.length}");
        return depthInfoEntityList;
      }
      return [];
    }

    var buy = dataMap["buy"];
    var buyList = deptList(buy, "buy");

    var sell = dataMap["sell"];
    var sellList = deptList(sell, "sell");
    print("[WS] --> _getDepthData,buyList.length:${buyList.length}, sellList.length:${sellList.length}");

    if (isReplace) {
      if (buyList.isNotEmpty) {
        _buyDepthItemList = buyList;
      }

      if (sellList.isNotEmpty) {
        _sellDepthItemList = sellList;
      }
    } else {
      if (buyList.isNotEmpty) {
        _buyDepthItemList.addAll(buyList);
      }

      if (sellList.isNotEmpty) {
        _sellDepthItemList.addAll(sellList);
      }
    }

    // doing
    List<ExcDetailEntity> buyEntityList = [];
    List<ExcDetailEntity> sellEntityList = [];

    for (int index = 0; index < min(10, min(_buyDepthItemList.length, _sellDepthItemList.length)); index++) {
      var right = (index + 1);
      var left = 10 - right;
      var buy = _buyDepthItemList[index];
      var entity = ExcDetailEntity(2, left, right, depthEntity: buy);
      buyEntityList.add(entity);

      left = index + 1;
      right = 10 - left;
      var sell = _sellDepthItemList[index];
      entity = ExcDetailEntity(2, left, right, depthEntity: sell);
      sellEntityList.add(entity);
    }

    if (buyEntityList.isNotEmpty) {
      _buyChartList = buyEntityList;
    }

    if (sellEntityList.isNotEmpty) {
      _sellChartList = sellEntityList;
    }

    setState(() {});
  }

  // channel
  _initChannel() {
    _sub24HourChannel();
    _subPeriodChannel();
    _subDepthChannel();
    _subTradeChannel();

    _initListenChannel();
  }

  _unSubChannels() {
    _unSub24HourChannel();
    _unSubPeriodChannel();
    _unSubDepthChannel();
    _unSubTradeChannel();
  }

  // 24hour
  void _sub24HourChannel() {
    var channel = SocketConfig.channelKLine24Hour;
    _subChannel(channel);
  }

  void _unSub24HourChannel() {
    var channel = SocketConfig.channelKLine24Hour;
    _unSubChannel(channel);
  }

  // period
  void _subPeriodChannel() {
    var channel = SocketConfig.channelKLinePeriod(_symbol, _periodParameter.value);
    _subChannel(channel);
  }

  void _unSubPeriodChannel({String period = ''}) {
    var channel = SocketConfig.channelKLinePeriod(_symbol, period.isEmpty ? _periodParameter.value : period);
    _unSubChannel(channel);
  }

  // trade
  void _subTradeChannel() {
    var channel = SocketConfig.channelTradeDetail(_symbol);
    _subChannel(channel);
  }

  void _unSubTradeChannel() {
    var channel = SocketConfig.channelTradeDetail(_symbol);
    _unSubChannel(channel);
  }

  // depth
  void _subDepthChannel() {
    var channel = SocketConfig.channelExchangeDepth(_symbol, -1);
    _subChannel(channel);
  }

  void _unSubDepthChannel() {
    var channel = SocketConfig.channelExchangeDepth(_symbol, -1);
    _unSubChannel(channel);
  }

  // sub
  void _subChannel(String channel) {
    BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: channel));
  }

  // unSub
  void _unSubChannel(String channel) {
    BlocProvider.of<SocketBloc>(context).add(UnSubChannelEvent(channel: channel));
  }

  void _initListenChannel() {
    BlocProvider.of<SocketBloc>(context).listen((state) {
      if (state is SubChannelSuccessState) {
        var msg = '订阅 ${state.channel} 成功';
        print("[Bloc] msg:$msg");
        //Fluttertoast.showToast(msg: msg);
      } else if (state is UnSubChannelSuccessState) {
        var msg = '取阅 ${state.channel} 成功';
        print("[Bloc] msg:$msg");
        //Fluttertoast.showToast(msg: msg);
      } else if (state is ChannelKLine24HourState) {
        _dealPeriodData(state.response, symbol: state.symbol);
      } else if (state is ChannelKLinePeriodState) {
        if (!(state.channel?.endsWith(_periodParameter.value) ?? true)) {
          _unSubPeriodChannel(period: state.channel.split(".").last);
          print("[WS] 取消不是当前选中的channel:${state.channel}");
        }
        _dealPeriodData(state.response, isReplace: false);
      } else if (state is ChannelExchangeDepthState) {
        _dealDepthData(state.response, isReplace: false);
      } else if (state is ChannelTradeDetailState) {
        _dealTradeData(state.response, isReplace: false);
      }
    });
  }
}

Widget delegationListView(List<ExcDetailEntity> buyChartList, List<ExcDetailEntity> sailChartList) {
  return Container(
    padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
    color: Colors.white,
    child: Column(
      children: <Widget>[
        Container(
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
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              ExcDetailEntity buyEntity = buyChartList[index];
              ExcDetailEntity sailEntity = sailChartList[index];

              return Row(
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
                                  "${index + 1}",
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
                                  buyEntity?.depthEntity?.amount?.toString() ?? "--",
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
                                    buyEntity?.depthEntity?.price?.toString() ?? "--",
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
                                    sailEntity?.depthEntity?.price?.toString() ?? "--",
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
                                  sailEntity?.depthEntity?.amount?.toString() ?? "--",
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
                                  "${index + 1}",
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
      ],
    ),
  );
}
