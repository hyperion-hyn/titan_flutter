import 'dart:async';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:titan/src/pages/market/entity/trade_info_entity.dart';
import 'package:titan/src/utils/format_util.dart';

class KLineDetailPage extends StatefulWidget {
  final String symbol;
  final String symbolName;

  KLineDetailPage({this.symbol, this.symbolName});

  @override
  State<StatefulWidget> createState() {
    return _KLineDetailPageState();
  }
}

class _KLineDetailPageState extends BaseState<KLineDetailPage> with TickerProviderStateMixin {
  final ExchangeApi api = ExchangeApi();
  SocketBloc _socketBloc;
  List<KLineEntity> _kChartItemList = [];
  List<TradeInfoEntity> _tradeItemList = [];

  PeriodInfoEntity _periodParameter;

  bool _showLoadingKLine = true;
  bool _showLoadingDepth = true;
  bool _showLoadingTrade = true;

  bool _isShowMore = false;
  bool _isShowSetting = false;

  bool get _isDepth => _periodTabController.index == 5;

  bool get _isLine => _periodParameter.name == _morePeriodList.first.name;

//  注：period类型有如下”：'1min', '5min', '15min', '30min', '60min', '1day', '1week'，"1mon"
  List<PeriodInfoEntity> _normalPeriodList = [
    PeriodInfoEntity(name: "15分钟", value: "15min"),
    PeriodInfoEntity(name: "60分钟", value: "60min"),
    PeriodInfoEntity(name: "5分钟", value: "5min"),
    PeriodInfoEntity(name: "1天", value: "1day")
  ];

  List<PeriodInfoEntity> _morePeriodList = [
    PeriodInfoEntity(name: "分时", value: "分时"),
    PeriodInfoEntity(name: "1分钟", value: "1min"),
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

  List<DepthEntity> _bids = []; // 出价， 竞标
  List<DepthEntity> _asks = []; // 询价

  var _kMaxTradeCount = 20;

  StreamController<int> _amount24HourController = StreamController.broadcast();
  final int _amount24HourRefresh = 15;

  StreamController<int> _depthController = StreamController.broadcast();
  final int _depthRefresh = 16;

  StreamController<int> _tradeController = StreamController.broadcast();
  final int _tradeRefresh = 17;

  @override
  void initState() {
    _initData();

    _setupRequest();

    super.initState();
  }

  @override
  void onCreated() {
    _socketBloc = BlocProvider.of<SocketBloc>(context);

    _initChannel();

    super.onCreated();
  }

  @override
  void dispose() {
    _unSubChannels();

    _socketBloc = null;
    print("[KLine] dispose");
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'HYN/${widget.symbolName}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerWidget() {
    var marketItemEntity = MarketInheritedModel.of(context).getMarketItem(widget.symbol);

    var _high = marketItemEntity.kLineEntity?.high?.toString() ?? "--";
    var _low = marketItemEntity.kLineEntity?.low?.toString() ?? "--";
    var _amount24Hour = marketItemEntity.kLineEntity?.amount?.toString() ?? "--";

    // price
    var _latestPrice = FormatUtil.truncateDecimalNum(
      Decimal.parse(marketItemEntity.kLineEntity.close.toString()),
      4,
    );
    var _latestPriceString = '${_latestPrice ?? '--'}';

    var _selectedQuote = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(
      marketItemEntity.symbolName,
    );
    var _latestQuotePrice = _selectedQuote == null
        ? '--'
        : FormatUtil.truncateDoubleNum(
            double.parse(_latestPrice) * _selectedQuote?.quoteVo?.price,
            4,
          );
    var _latestRmbPriceString = '${_selectedQuote?.sign?.sign ?? ''} $_latestQuotePrice';

    // _latestPercent
    double _latestPercent = MarketInheritedModel.of(context).getRealTimePricePercent(
      marketItemEntity.symbol,
    );
    var _latestPercentBgColor = _latestPercent == 0
        ? HexColor('#FF999999')
        : _latestPercent > 0 ? HexColor('#FF53AE86') : HexColor('#FFCC5858');
    var _latestPercentString = '${(_latestPercent) > 0 ? ' +' : ' '}${FormatUtil.truncateDoubleNum(
      _latestPercent * 100.0,
      2,
    )}%';

    return SliverToBoxAdapter(
      child: StreamBuilder(
        stream: _amount24HourController.stream,
        builder: (context, optionType) {
          return Container(
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
                            _latestPriceString,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 28, color: _latestPercentBgColor),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          RichText(
                            text: TextSpan(
                                text: _latestRmbPriceString,
                                style: TextStyle(
                                  color: HexColor("#777777"),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                      text: _latestPercentString,
                                      style: TextStyle(
                                        color: _latestPercentBgColor,
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
                          children: [_high, '1', _low, '1', _amount24Hour]
                              .map((text) => text == '1'
                                  ? SizedBox(
                                      height: 6,
                                    )
                                  : Text(
                                      text,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500, fontSize: 10, color: HexColor("#333333")),
                                    ))
                              .toList()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
              child: DepthChart(_bids, _asks),
//              child: Text("修改数据源"),
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
        _periodTabController.index = 4;

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
                  color: _isShowMore || (_morePeriodList.contains(_periodParameter) && _periodCurrentIndex == 4)
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
          fontSize: 12,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: EdgeInsets.only(left: 16),
        indicatorColor: HexColor('#228BA1'),
        indicatorPadding: EdgeInsets.only(bottom: 8, left: 20, right: 4),
        unselectedLabelColor: HexColor("#999999"),
        onTap: (int index) {
          _lastSelectedIndex = _periodTabController.previousIndex;

          if (index == 4) {
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
                Visibility(
                    visible: !_showLoadingDepth,
                    child: StreamBuilder(
                      stream: _depthController.stream,
                      builder: (context, optionType) {
                        return delegationListView(_buyChartList, _sellChartList, enable: false);
                      },
                    )),
                _loadingWidget(visible: _showLoadingDepth),
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
    return StreamBuilder(
        stream: _tradeController.stream,
        builder: (context, snapshot) {
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
                                FormatUtil.formatSecondDate(excDetailEntity.date),
//                          FormatUtil.formatDate(excDetailEntity.date, isSecond: true, isMillisecond: true),
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
        });
  }

  _initData() {
    _periodParameter = _normalPeriodList[0];

    _detailTabController = TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );

    _periodTabController = TabController(
      initialIndex: _periodCurrentIndex,
      vsync: this,
      length: 7,
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
    if (mounted) {
      setState(() {
        _showLoadingKLine = true;
      });
    }

    var data = await api.historyKline(widget.symbol, period: _periodParameter.value);
    print("[WS] --> _getPeriodData, data:$data");
    _dealPeriodData(data);

    if (mounted) {
      setState(() {
        _showLoadingKLine = false;
      });
    }
  }

  _dealPeriodData(dynamic data, {bool isReplace = true}) {
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
            'amount': double.parse(itemList[6].toString()),
            'count': 0,
            'id': int.parse(itemList[0].toString()) / 1000,
          };
        }
      }

      return KLineEntity.fromJson(json);
    }).toList();
    print("[WS] --> _dealPeriodData, kLineDataList.length:${kLineDataList?.length}, symbol:${widget.symbol}");

    if (isReplace) {
      if (kLineDataList.isNotEmpty) {
        _kChartItemList = kLineDataList;
        DataUtil.calculate(_kChartItemList);
      }
    } else {
      if (kLineDataList.isNotEmpty) {
        DataUtil.addLastData(_kChartItemList, kLineDataList.last);
      }
    }
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
    var data = await api.historyTrade(widget.symbol, limit: (_kMaxTradeCount * 2).toString());

    print("[WS] --> _getTradeData, data:$data");

    _dealTradeData(data);
    print("[WS] --> _getTradeData, data:${data is List}");

    if (mounted) {
      setState(() {
        _showLoadingTrade = false;
      });
    }
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

    //print("[WS] --> _dealTradeData, 1,tradeInfoEntityList.length:${tradeInfoEntityList.length}");

    if (isReplace) {
      if (tradeInfoEntityList.isNotEmpty) {
        if (tradeInfoEntityList.length > _kMaxTradeCount) {
          _tradeItemList = tradeInfoEntityList.sublist(0, _kMaxTradeCount);
        } else {
          _tradeItemList = tradeInfoEntityList;
        }
      }
    } else {
      if (tradeInfoEntityList.isNotEmpty) {
        tradeInfoEntityList = tradeInfoEntityList.reversed.toList();
        _tradeItemList.insertAll(0, tradeInfoEntityList);
        if (_tradeItemList.length > _kMaxTradeCount) {
          _tradeItemList = _tradeItemList.sublist(0, _kMaxTradeCount);
        }
      }
    }
    //print("[WS] --> _dealTradeData, 2,_tradeItemList.length:${_tradeItemList.length}");
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
    var data = await api.historyDepth(widget.symbol);
    print("[WS] --> _getDepthData, data:$data");

    _buyChartList.clear();
    _sellChartList.clear();
    dealDepthData(_buyChartList, _sellChartList, data);
    _setupDepthWidget();
    print("[WS] --> _getDepthData, _buyChartList.length:${_buyChartList.length}");

    if (mounted) {
      setState(() {
        _showLoadingDepth = false;
      });
    }
  }

  void _setupDepthWidget() {

    // buy: high --> low
    _bids.clear();
    _buyChartList.forEach((element) {
      var amount = element.depthEntity.amount;
      if (_bids.isNotEmpty) {
        var first = _bids.first;
        amount += first.amount;
      }
      DepthEntity entity = DepthEntity(element.depthEntity.price, amount);
      _bids.insert(0, entity);
    });

    // sell: low --> high
    _asks.clear();
    _sellChartList.forEach((element) {
      var amount = element.depthEntity.amount;
      if (_asks.isNotEmpty) {
        var last = _asks.last;
        amount += last.amount;
      }
      DepthEntity entity = DepthEntity(element.depthEntity.price, amount);
      _asks.add(entity);
    });

  }



  // channel
  _initChannel() {
    _subPeriodChannel();
    _subDepthChannel();
    _subTradeChannel();

    _initListenChannel();
  }

  _unSubChannels() {
    _unSubPeriodChannel();
    _unSubDepthChannel();
    _unSubTradeChannel();
  }

  // period
  void _subPeriodChannel() {
    var channel = SocketConfig.channelKLinePeriod(widget.symbol, _periodParameter.value);
    _subChannel(channel);
  }

  void _unSubPeriodChannel({String period = ''}) {
    var channel = SocketConfig.channelKLinePeriod(widget.symbol, period.isEmpty ? _periodParameter.value : period);
    _unSubChannel(channel);
  }

  // trade
  void _subTradeChannel() {
    var channel = SocketConfig.channelTradeDetail(widget.symbol);
    _subChannel(channel);
  }

  void _unSubTradeChannel() {
    var channel = SocketConfig.channelTradeDetail(widget.symbol);
    _unSubChannel(channel);
  }

  // depth
  void _subDepthChannel() {
    var channel = SocketConfig.channelExchangeDepth(widget.symbol, -1);
    _subChannel(channel);
  }

  void _unSubDepthChannel() {
    var channel = SocketConfig.channelExchangeDepth(widget.symbol, -1);
    _unSubChannel(channel);
  }

  // sub
  void _subChannel(String channel) {
    if (_socketBloc == null) return;

    _socketBloc.add(SubChannelEvent(channel: channel));
  }

  // unSub
  void _unSubChannel(String channel) {
    if (_socketBloc == null) return;

    _socketBloc.add(UnSubChannelEvent(channel: channel));
  }

  void _initListenChannel() {
    if (_socketBloc == null) return;

    _socketBloc.listen((state) {
      if (state is SubChannelSuccessState) {
        var msg = '订阅 ${state.channel} 成功';
        print("[Bloc] msg:$msg");
        //Fluttertoast.showToast(msg: msg);
      } else if (state is UnSubChannelSuccessState) {
        var msg = '取阅 ${state.channel} 成功';
        print("[Bloc] msg:$msg");
        //Fluttertoast.showToast(msg: msg);
      } else if (state is ChannelKLine24HourState) {
        _amount24HourController.add(_amount24HourRefresh);
      } else if (state is ChannelKLinePeriodState) {
        if (!(state.channel?.endsWith(_periodParameter.value) ?? true)) {
          _unSubPeriodChannel(period: state.channel.split(".").last);
          print("[WS] 取消不是当前选中的channel:${state.channel}");
        }
        _dealPeriodData(state.response, isReplace: false);
      } else if (state is ChannelExchangeDepthState) {
        _buyChartList.clear();
        _sellChartList.clear();
        dealDepthData(_buyChartList, _sellChartList, state.response);
        _setupDepthWidget();
        _depthController.add(_depthRefresh);
      } else if (state is ChannelTradeDetailState) {
        _dealTradeData(state.response, isReplace: false);
        _tradeController.add(_tradeRefresh);
      }
    });
  }
}

Widget delegationListView(List<ExcDetailEntity> buyChartList, List<ExcDetailEntity> sellChartList,
    {limitNum = 20, enable = true, Function clickPrice}) {
  return Container(
    padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
    color: Colors.white,
    child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: enable
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Text(
                            "买",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: HexColor("#777777"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "数量",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: HexColor("#777777"),
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "买价",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: HexColor("#777777"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Text(
                            "卖价",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: HexColor("#777777"),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              "数量",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: HexColor("#777777"),
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "卖",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: HexColor("#777777"),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : Row(
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
              ExcDetailEntity buyEntity;
              if (buyChartList.length > index) {
                buyEntity = buyChartList[index];
              }

              ExcDetailEntity sellEntity;
              if (sellChartList.length > index) {
                sellEntity = sellChartList[index];
              }
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
                                flex: buyEntity?.leftPercent ?? 0,
                                child: Container(
                                  height: 25,
                                  color: HexColor("#ffffff"),
                                ),
                              ),
                              Expanded(
                                flex: buyEntity?.rightPercent ?? 0,
                                child: Container(
                                  height: 25,
                                  color: HexColor("#EBF8F2"),
                                ),
                              )
                            ],
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              //splashColor: Colors.greenAccent,
                              highlightColor: HexColor("#D8F3E7"),

                              onTap: enable
                                  ? () {
                                      var depthPrice = buyEntity?.depthEntity?.price.toString() ?? "0";
                                      clickPrice(depthPrice);
                                      print("[KLINE] 当前选中价格：${buyEntity?.depthEntity?.price?.toString() ?? "--"}");
                                    }
                                  : null,

                              child: Row(
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
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    width: 3,
                  ),
                  Expanded(
                      flex: 1,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: sellEntity?.leftPercent ?? 0,
                                child: Container(
                                  height: 25,
                                  color: HexColor("#F9EFEF"),
                                ),
                              ),
                              Expanded(
                                flex: sellEntity?.rightPercent ?? 0,
                                child: Container(
                                  height: 25,
                                  color: HexColor("#ffffff"),
                                ),
                              )
                            ],
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              //splashColor: Colors.greenAccent,
                              highlightColor: HexColor("#FAE4E4"),

                              onTap: enable
                                  ? () {
                                      clickPrice(sellEntity?.depthEntity?.price.toString() ?? "0");
                                      print("[KLINE] 当前选中价格：${sellEntity?.depthEntity?.price?.toString() ?? "--"}");
                                    }
                                  : null,

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 25,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        sellEntity?.depthEntity?.price?.toString() ?? "--",
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
                                      sellEntity?.depthEntity?.amount?.toString() ?? "--",
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
                            ),
                          ),
                        ],
                      )),
                ],
              );
            },
            itemCount: limitNum == 20 ? max(buyChartList.length, sellChartList.length) : limitNum),
      ],
    ),
  );
}

dealDepthData(List<ExcDetailEntity> buyChartList, List<ExcDetailEntity> sellChartList, dynamic data) {
  if (!(data is Map)) {
    return;
  }

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
      //print("[WS] --> _getDepthData, depthInfoEntityList.length:${depthInfoEntityList.length}");
      return depthInfoEntityList;
    }
    return [];
  }

  DepthInfoEntity maxDepthEntity(List<DepthInfoEntity> list) {
    return list.reduce((DepthInfoEntity current, DepthInfoEntity next) {
      if (current.amount > next.amount) {
        return current;
      }
      return next;
    });
  }

  // buy
  var buyList = deptList(data["buy"], "buy");
  if (buyList.isNotEmpty) {
    var max = maxDepthEntity(buyList);
    for (int index = 0; index < buyList.length; index++) {
      var buy = buyList[index];
      var right = 10 * buy.amount ~/ max.amount;
      var left = 10 - right;
      var entity = ExcDetailEntity(2, left, right, depthEntity: buy);
      buyChartList.add(entity);
    }
  }

  // sell
  var sellList = deptList(data["sell"], "sell");
  if (sellList.isNotEmpty) {
    var max = maxDepthEntity(sellList);
    for (int index = 0; index < sellList.length; index++) {
      var sell = sellList[index];
      var left = 10 * sell.amount ~/ max.amount;
      var right = 10 - left;
      var entity = ExcDetailEntity(4, left, right, depthEntity: sell);
      sellChartList.add(entity);
    }
  }

  print(
      "[WS] --> _getDepthData,buyChartList.length:${buyChartList.length}, sellChartList.length:${sellChartList.length}");
}
