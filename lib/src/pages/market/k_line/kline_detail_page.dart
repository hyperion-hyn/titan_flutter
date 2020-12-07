import 'dart:async';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:titan/src/pages/market/entity/trade_info_entity.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/utils/format_util.dart';

class KLineDetailPage extends StatefulWidget {
  final String symbol;
  final bool isPop;
  final int periodCurrentIndex;
  final String quote;
  final String base;

  KLineDetailPage({
    this.symbol,
    this.isPop,
    this.periodCurrentIndex,
    this.quote,
    this.base,
  });

  @override
  State<StatefulWidget> createState() {
    return _KLineDetailPageState();
  }
}

class _KLineDetailPageState extends BaseState<KLineDetailPage>
    with TickerProviderStateMixin {
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

  bool get _isDepth => (_periodTabController?.index ?? 0) == 5;

  bool _isLine = false;

  //bool get _isLine => _periodParameter.name == _morePeriodList.first.name;

//  注：period类型有如下”：'1min', '5min', '15min', '30min', '60min', '1day', '1week'，"1mon"
  List<PeriodInfoEntity> _normalPeriodList = [
    PeriodInfoEntity(name: "5分钟", value: "5min"),
    PeriodInfoEntity(name: "15分钟", value: "15min"),
    PeriodInfoEntity(name: "60分钟", value: "60min"),
    PeriodInfoEntity(name: "1天", value: "1day")
  ];

  List<PeriodInfoEntity> _morePeriodList = [
//    PeriodInfoEntity(name: "分时", value: "分时"),
    PeriodInfoEntity(name: "1分钟", value: "1min"),
    PeriodInfoEntity(name: "30分钟", value: "30min"),
    PeriodInfoEntity(name: "1周", value: "1week"),
    PeriodInfoEntity(name: "1月", value: "1mon"),
  ];

//  MainState _mainState = MainState.MA;
//  SecondaryState _secondaryState = SecondaryState.MACD;
  MainState _mainState = MainState.NONE;
  SecondaryState _secondaryState = SecondaryState.NONE;

  bool get _isOpenMainState => _mainState != MainState.NONE;

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

  // StreamController<int> _amount24HourController = StreamController.broadcast();
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

    _setupTranslate();

    super.onCreated();
  }

  _setupTranslate() {
    _normalPeriodList = [
      PeriodInfoEntity(name: S.of(context).kline_period_5min, value: "5min"),
      PeriodInfoEntity(name: S.of(context).kline_period_15min, value: "15min"),
      PeriodInfoEntity(name: S.of(context).kline_period_60min, value: "60min"),
      PeriodInfoEntity(name: S.of(context).kline_period_1day, value: "1day")
    ];

    _morePeriodList = [
//      PeriodInfoEntity(name: S.of(context).kline_period_min, value: "分时"),
      PeriodInfoEntity(name: S.of(context).kline_period_1min, value: "1min"),
      PeriodInfoEntity(name: S.of(context).kline_period_30min, value: "30min"),
      PeriodInfoEntity(name: S.of(context).kline_period_1week, value: "1week"),
      PeriodInfoEntity(name: S.of(context).kline_period_1mon, value: "1mon"),
    ];
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
          child: Column(
            children: <Widget>[
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    _headerWidget(),
                    _dividerWidget(),
                    _periodTabWidget(),
                    _dividerWidget(height: 1.0),
                    _kLineWidget(),
                    _dividerWidget(),
                    _detailTabWidget(),
                    _detailHeaderWidget(),
                    _detailWidget(),
                  ],
                ),
              ),
              _bottomSureButtonWidget(),
            ],
          ),
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
                  '${widget.quote}/${widget.base}',
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

  Widget _bottomSureButtonWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            //color: Colors.black38,
            color: HexColor("#000000").withOpacity(0.08),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                textColor: Colors.white,
                disabledColor: Colors.grey[600],
                disabledTextColor: Colors.white,
                color: HexColor("#53AE86"),
                child: Text(S.of(context).exchange_buy,
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                onPressed: () {
                  _buySellAction(ExchangeType.BUY);
                },
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: FlatButton(
                textColor: Colors.white,
                disabledColor: Colors.grey[600],
                disabledTextColor: Colors.white,
                color: HexColor("#CC5858"),
                child: Text(S.of(context).exchange_sell,
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                onPressed: () {
                  _buySellAction(ExchangeType.SELL);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buySellAction(int exchangeType) {
    if (widget.isPop) {
      Navigator.pop(context, exchangeType);
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExchangeDetailPage(
              exchangeType: exchangeType,
              base: widget.base,
              quote: widget.quote,
            ),
          ));
    }
  }

  Widget _headerWidget() {
    var marketItemEntity =
        MarketInheritedModel.of(context, aspect: SocketAspect.marketItemList)
            .getMarketItem(widget.symbol);

    var _high = marketItemEntity?.kLineEntity?.high?.toString() ?? "--";
    var _low = marketItemEntity?.kLineEntity?.low?.toString() ?? "--";
    var _amount24Hour =
        marketItemEntity?.kLineEntity?.amount?.toString() ?? "--";

    // price
    var close = marketItemEntity?.kLineEntity?.close;
    var closeValue = close ?? 0;
    var _latestPrice = FormatUtil.truncateDecimalNum(
      Decimal.parse(closeValue.toString()),
      4,
    );
    var _latestPriceString = '${_latestPrice ?? '--'}';

    // _latestPercent
    double _latestPercent =
        MarketInheritedModel.of(context, aspect: SocketAspect.marketItemList)
            .getRealTimePricePercent(
      marketItemEntity?.symbol,
    );

    var _latestPercentBgColor = _latestPercent == 0
        ? HexColor('#FF999999')
        : _latestPercent > 0
            ? HexColor('#FF53AE86')
            : HexColor('#FFCC5858');
    var _latestPercentString =
        '${(_latestPercent) > 0 ? ' +' : ' '}${FormatUtil.truncateDoubleNum(
      _latestPercent * 100.0,
      2,
    )}%';

    var _latestQuotePriceString = '--';

    try {
      var _selectedQuote =
          WalletInheritedModel.of(context).activatedQuoteVoAndSign(
        marketItemEntity?.base,
      );
      var _latestQuotePrice = FormatUtil.truncateDoubleNum(
        double.parse(_latestPrice) * _selectedQuote?.quoteVo?.price,
        4,
      );
      _latestQuotePriceString =
          '${_selectedQuote?.sign?.sign ?? ''} $_latestQuotePrice';
    } catch (e) {}

    return SliverToBoxAdapter(
      child: Container(
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
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 28,
                            color: _latestPercentBgColor),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      RichText(
                        text: TextSpan(
                            text: _latestQuotePriceString,
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
                          S.of(context).kline_24h_high,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                              color: HexColor("#999999")),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          S.of(context).kline_24h_low,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                              color: HexColor("#999999")),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '24H',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                              color: HexColor("#999999")),
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      color: HexColor("#333333")),
                                ))
                          .toList()),
                ],
              ),
            ),
          ],
        ),
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
    var locale =
        SettingInheritedModel.of(context, aspect: SettingAspect.language)
                ?.languageModel
                ?.getLocaleName() ??
            'zh';
    //print("[KLine] local:$local");

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
              bgColor: [Colors.white, Colors.white],
              mainState: _mainState,
              secondaryState: _secondaryState,
              locale: locale,
              fixedLength: 4,
//              fractionDigits: 4,
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
            child: Column(
              children: <Widget>[
                Container(
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
                        .map((item) => _periodTextWidget(item))
                        .toList(),
                  ),
                ),
                /*InkWell(
                  onTap: (){
                    _clickMoreAction(4);
                  },
                  child: Container(
                    height: 200,
                  ),
                ),*/
              ],
            ),
          ),
          Visibility(
            visible: _isShowSetting,
            child: Column(
              children: <Widget>[
                Container(
                  //duration: Duration(milliseconds: 333),
                  margin: EdgeInsets.only(left: 14, top: 3, right: 14),
                  width: double.infinity,
                  //height: 100,
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
                              //"主图",
                              S.of(context).kline_state_main,
                              style: TextStyle(
                                  color: HexColor("#333333"), fontSize: 12),
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
                              S.of(context).kline_state_secondary,
                              style: TextStyle(
                                  color: HexColor("#333333"), fontSize: 12),
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
                InkWell(
                  onTap: _clickSettingAction,
                  child: Container(
                    height: 200,
                  ),
                ),
              ],
            ),
          ),
          _loadingWidget(visible: _showLoadingKLine, height: kLineHeight),
        ],
      ),
    );
  }

  Widget get _spacerWidget => SizedBox(
        width: SettingInheritedModel.of(context, aspect: SettingAspect.language)
                    ?.languageModel
                    ?.isKo() ??
                false
            ? 15
            : 18,
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
          color: isOpen ? HexColor("#228BA1") : HexColor("#999999"),
        ),
      ),
      onPressed: () async {
        if (isOpen) {
          setState(() {
            if (isMain) {
              _mainState = MainState.NONE;
            } else {
              _secondaryState = SecondaryState.NONE;
            }
          });
        } else {
          var prefs = await SharedPreferences.getInstance();

          setState(() {
            if (isMain) {
              var mainStateValue = prefs.getInt(PrefsKey.KLINE_MAIN_STATE) ?? 0;
              _mainState = MainState.values[mainStateValue];
            } else {
              var secondaryStateValue =
                  prefs.getInt(PrefsKey.KLINE_SECONDARY_STATE) ?? 0;
              _secondaryState = SecondaryState.values[secondaryStateValue];
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
      onTap: () async {
        setState(() {
          if (isMain) {
            _mainState = enumMainStateFromString(title);
          } else {
            _secondaryState = enumSecondaryStateFromString(title);
          }
        });

        var prefs = await SharedPreferences.getInstance();
        if (isMain) {
          prefs.setInt(PrefsKey.KLINE_MAIN_STATE, _mainState.index);
        } else {
          prefs.setInt(PrefsKey.KLINE_SECONDARY_STATE, _secondaryState.index);
        }
      },
      child: Container(
        //color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(
          title,
          style: TextStyle(
              color: isSelected ? HexColor("#228BA1") : HexColor("#999999"),
              fontSize: 12),
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

        // old
        _unSubPeriodChannel();
        _periodParameter = item;
        _getPeriodData();

        // new
        _subPeriodChannel();

        /* var index = _morePeriodList.indexOf(item);
        if (index != 0) {
          // old
          _unSubPeriodChannel();
          _periodParameter = item;
          _getPeriodData();
          // new
          _subPeriodChannel();
        } else {
          _periodParameter = item;
        }*/

        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          item.name,
          style: TextStyle(
              color: item.name == equalValue.name
                  ? HexColor("#228BA1")
                  : HexColor("#999999"),
              fontSize: 12),
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
              _morePeriodList.contains(_periodParameter)
                  ? _periodParameter.name
                  : S.of(context).kline_period_more,
              style: TextStyle(
                  color: _isShowMore ||
                          (_morePeriodList.contains(_periodParameter) &&
                              _periodCurrentIndex == 4)
                      ? HexColor("#228BA1")
                      : HexColor("#999999")),
            ),
            Image.asset(
              'res/drawable/k_line_down_arrow.png',
              width: 5,
              height: 5,
              color: _isShowMore ||
                      (_morePeriodList.contains(_periodParameter) &&
                          _periodCurrentIndex == 3)
                  ? HexColor("#228BA1")
                  : HexColor("#999999"),
            ),
          ],
        ),
      ),
      Tab(
        child: Text(
          //'深度图',
          S.of(context).kline_period_depth,
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
          onPressed: _clickSettingAction,
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
          _clickMoreAction(index);
        },
        tabs: tabs,
      ),
    );
  }

  _clickSettingAction() {
    _isShowMore = false;
    _isShowSetting = !_isShowSetting;
    setState(() {});
  }

  _clickMoreAction(int index) async {
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

    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(PrefsKey.PERIOD_CURRENT_INDEX, _periodCurrentIndex);
    //print("[API] 2, _periodCurrentIndex:$_periodCurrentIndex");

    if (index < _normalPeriodList.length) {
      // old
      _unSubPeriodChannel();
      // new
      _periodParameter = _normalPeriodList[index];
      _getPeriodData();
      _subPeriodChannel();
    }

    setState(() {});
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

          if (index == 0) {
            if (_buyChartList.isEmpty || _sellChartList.isEmpty) {
              if (mounted) {
                setState(() {
                  _showLoadingDepth = true;
                });
              }
              _getDepthData();
            }
          } else {
            if (_tradeItemList.isEmpty) {
              if (mounted) {
                setState(() {
                  _showLoadingTrade = true;
                });
              }
              _getTradeData();
            }
          }
        },
        tabs: [
          Tab(
            child: Text(
              //"挂单委托",
              S.of(context).kline_tab_delegation,
              style: TextStyle(),
            ),
          ),
          Tab(
            child: Text(
              //'成交',
              S.of(context).kline_tab_market,
              style: TextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailHeaderWidget() {

    var priceStr = S.of(context).kline_delegate_price;
    var amountStr = S.of(context).kline_delegate_amount;
    if (widget.quote == 'USDT') {
      priceStr = S.of(context).kline_delegate_price;
      amountStr = S.of(context).kline_delegate_amount;
    } else {
      priceStr = '价格(HYN)';
      amountStr = '数量(RP)';
    }


    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 20,
          left: 12,
          right: 12,
          top: 12,
        ),
        child: (_detailCurrentIndex == 1)
            ? Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                      S.of(context).kline_delegate_time,
                      style:
                          TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      S.of(context).kline_delegate_direction,
                      style:
                          TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      priceStr,
                      textAlign: TextAlign.end,
                      style:
                          TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      amountStr,
                      textAlign: TextAlign.end,
                      style:
                          TextStyle(color: HexColor("#777777"), fontSize: 10),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    //"买盘 数量(HYN)",
                    S.of(context).kline_delegate_buy +
                        " " +
                        '${S.of(context).kline_delegate_amount_v2}(${widget.quote})',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: HexColor("#777777"),
                    ),
                  ),
                  Text(
                    //"价格(USDT)",
                    '${S.of(context).price} (${widget.base})',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: HexColor("#777777"),
                    ),
                  ),
                  Text(
                    //"数量(HYN)卖盘",
                    '(${widget.quote})' +
                        S.of(context).kline_delegate_amount_v2 +
                        " " +
                        S.of(context).kline_delegate_sell,
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
    );
  }

  Widget _detailWidget() {
    if (_detailCurrentIndex == 1) {
      if (!_showLoadingTrade) {
        return _tradeListViewContent();
      } else {
        return _loadingWidget(visible: _showLoadingTrade, isDetail: true);
      }
    } else {
      if (!_showLoadingDepth) {
        return _depthListViewContent();
      } else {
        return _loadingWidget(visible: _showLoadingDepth, isDetail: true);
      }
    }
  }

  Widget _tradeListViewContent() {
    //print("_tradeItemList:${_tradeItemList.length}");

    return StreamBuilder<Object>(
        stream: _tradeController.stream,
        builder: (context, snapshot) {
          return SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) {
              var excDetailEntity = _tradeItemList[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                  left: 12,
                  right: 12,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        FormatUtil.formatSecondDate(excDetailEntity.date),
//                          FormatUtil.formatDate(excDetailEntity.date, isSecond: true, isMillisecond: true),
                        style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        excDetailEntity.actionType == "sell"
                            ? S.of(context).kline_direct_sell
                            : S.of(context).kline_direct_buy,
                        style: TextStyle(
                            color: HexColor(excDetailEntity.actionType == "sell"
                                ? "#CC5858"
                                : "#53AE86"),
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        excDetailEntity.price,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        excDetailEntity.amount,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: HexColor("#333333"),
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: _tradeItemList.length,
          ));
        });
  }

  Widget _depthListViewContent() {
    var buyChartList = _buyChartList;
    var sellChartList = _sellChartList;
    return StreamBuilder<Object>(
        stream: _depthController.stream,
        builder: (context, snapshot) {
          return SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) {
              ExcDetailEntity buyEntity;
              if (buyChartList.length > index) {
                buyEntity = buyChartList[index];
              }

              ExcDetailEntity sellEntity;
              if (sellChartList.length > index) {
                sellEntity = sellChartList[index];
              }
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Row(
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
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                          padding: EdgeInsets.only(
                                              left: index >= 9 ? 3 : 8),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            buyEntity?.depthEntity?.vol
                                                    ?.toString() ??
                                                "--",
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
                                            padding:
                                                const EdgeInsets.only(right: 5),
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              FormatUtil
                                                      .clearScientificCounting(
                                                          buyEntity?.depthEntity
                                                              ?.price) ??
                                                  "--",
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

                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            height: 25,
                                            alignment: Alignment.centerLeft,
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Text(
                                              FormatUtil
                                                      .clearScientificCounting(
                                                          sellEntity
                                                              ?.depthEntity
                                                              ?.price) ??
                                                  "--",
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
                                            sellEntity?.depthEntity?.vol
                                                    ?.toString() ??
                                                "--",
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
                                          padding: EdgeInsets.only(
                                              left: index >= 9 ? 3 : 8),
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
                    ),
                  ),
                  if ((index + 1) ==
                      max(buyChartList.length, sellChartList.length))
                    SizedBox(
                      height: 12,
                    ),
                ],
              );
            },
            childCount: max(buyChartList.length, sellChartList.length),
          ));
        });
  }

  Widget _loadingWidget(
      {bool visible = true, double height = 160, bool isDetail = false}) {
    //print("[$runtimeType] isDetail:$isDetail, _showLoadingTrade:$_showLoadingTrade, _showLoadingDepth:$_showLoadingDepth");

    var child = Visibility(
      visible: visible,
      child: Container(
        width: double.infinity,
        height: height,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
        ),
      ),
    );

    if (isDetail) {
      return SliverToBoxAdapter(
        child: child,
      );
    }

    return child;
  }

  _initData() async {
    _periodCurrentIndex = widget.periodCurrentIndex ?? 0;

    _periodParameter = _normalPeriodList[_periodCurrentIndex];

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

    var data =
        await api.historyKline(widget.symbol, period: _periodParameter.value);
    //print("[WS] --> _getPeriodData, data:$data");
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
//    print(
//        "[WS] --> _dealPeriodData:$isReplace, kLineDataList.length:${kLineDataList?.length}, symbol:${widget.symbol}");

    if (isReplace) {
      if (kLineDataList.isNotEmpty) {
        _kChartItemList = kLineDataList;
        DataUtil.calculate(_kChartItemList);
      }
    } else {
      if (kLineDataList.isNotEmpty && _kChartItemList.isNotEmpty) {
        var lastItem = _kChartItemList.last;
        var tempItem = kLineDataList.last;

        if (lastItem.time != tempItem.time) {
//          DataUtil.addLastData(_kChartItemList, tempItem);
          _kChartItemList.add(tempItem);
          DataUtil.calculate(_kChartItemList);
        } else {
          _kChartItemList.last = tempItem;
//          DataUtil.updateLastData(_kChartItemList);
          DataUtil.calculate(_kChartItemList);
        }
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
    var data = await api.historyTrade(widget.symbol,
        limit: (_kMaxTradeCount * 2).toString());

    //print("[WS] --> _getTradeData, data:$data");

    _dealTradeData(data);
    //print("[WS] --> _getTradeData, data:${data is List}");

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
    //print("[WS] --> _getDepthData, data:$data");

    _buyChartList.clear();
    _sellChartList.clear();
    dealDepthData(_buyChartList, _sellChartList, data, enable: false);
    _setupDepthWidget();
    //print("[WS] --> _getDepthData, _buyChartList.length:${_buyChartList.length}");

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
      var amount = element.depthEntity.vol;
      if (_bids.isNotEmpty) {
        var first = _bids.first;
        amount += first.vol;
      }
      DepthEntity entity = DepthEntity(element.depthEntity.price, amount);
      _bids.insert(0, entity);
    });

    // sell: low --> high
    _asks.clear();
    _sellChartList.forEach((element) {
      var amount = element.depthEntity.vol;
      if (_asks.isNotEmpty) {
        var last = _asks.last;
        amount += last.vol;
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
    var channel =
        SocketConfig.channelKLinePeriod(widget.symbol, _periodParameter.value);
    _subChannel(channel);
  }

  void _unSubPeriodChannel({String period = ''}) {
    var channel = SocketConfig.channelKLinePeriod(
        widget.symbol, period.isEmpty ? _periodParameter.value : period);
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

  // DebounceLater depthDebounceLater = DebounceLater();
  // DebounceLater tradeDebounceLater = DebounceLater();
  // DebounceLater klineDebounceLater = DebounceLater();

  void _initListenChannel() {
    if (_socketBloc == null) return;

    _socketBloc.listen((state) {
      if (state is SubChannelSuccessState) {
        //var msg = '订阅 ${state.channel} 成功';
        //print("[Bloc] msg:$msg");
        //Fluttertoast.showToast(msg: msg);
      } else if (state is UnSubChannelSuccessState) {
        //var msg = '取阅 ${state.channel} 成功';
        //print("[Bloc] msg:$msg");
        //Fluttertoast.showToast(msg: msg);
      } else if (state is ChannelKLine24HourState) {
        //24小时
        // _amount24HourController.add(_amount24HourRefresh);
      } else if (state is ChannelKLinePeriodState) {
        //蜡烛
        // klineDebounceLater.debounceInterval((){
        if (!(state.channel?.endsWith(_periodParameter.value) ?? true)) {
          _unSubPeriodChannel(period: state.channel.split(".").last);
          //print("[WS] 取消不是当前选中的channel:${state.channel}");
        }
        _dealPeriodData(state.response, isReplace: false);
        // }, 500);

      } else if (state is ChannelExchangeDepthState) {
        //订单深度
        // depthDebounceLater.debounceInterval(() {

        //var currentSymbol = "${widget.quote}/${widget.base}".toLowerCase();
        //print("[object] ---ChannelExchangeDepthState, response:${state.response}, currentSymbol:$currentSymbol");


        _buyChartList.clear();
        _sellChartList.clear();
        dealDepthData(_buyChartList, _sellChartList, state.response,
            enable: false);
        _setupDepthWidget();
        _depthController.add(_depthRefresh);


        // }, 500);
      } else if (state is ChannelTradeDetailState) {

        //var currentSymbol = "${widget.quote}/${widget.base}".toLowerCase();
        //print("[object] ---ChannelExchangeDepthState, state.symbol:${state.symbol}, currentSymbol:$currentSymbol, response:${state.response}");


        //成交
        // tradeDebounceLater.debounceInterval(() {
        _dealTradeData(state.response, isReplace: false);
        _tradeController.add(_tradeRefresh);
        // }, 500);


      }
    });
  }
}

Widget delegationListView(BuildContext context,
    List<ExcDetailEntity> buyChartList, List<ExcDetailEntity> sellChartList,
    {limitNum = 20, enable = true, Function clickPrice, String quote = 'USDT'}) {

  var priceStr = S.of(context).kline_delegate_price;
  var amountStr = S.of(context).kline_delegate_amount;
  if (quote == 'USDT') {
    priceStr = S.of(context).kline_delegate_price;
    amountStr = S.of(context).kline_delegate_amount;
  } else {
    priceStr = '价格(HYN)';
    amountStr = '数量(RP)';
  }

  return Container(
    padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 8),
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
                            //"买",
                            S.of(context).kline_market_buy,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: HexColor("#777777"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              //"数量",
                              S.of(context).kline_market_amount,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: HexColor("#777777"),
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            //"买价",
                            S.of(context).kline_market_buy_price,
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
                            //"卖价",
                            S.of(context).kline_market_sell_price,
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
                              //"数量",
                              S.of(context).kline_market_amount,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: HexColor("#777777"),
                              ),
                            ),
                          ),
                          Text(
                            //"卖",
                            S.of(context).kline_market_sell,
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
                      //"买盘 数量(HYN)",
                      S.of(context).kline_delegate_buy +
                          " " +
                          S.of(context).kline_delegate_amount,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: HexColor("#777777"),
                      ),
                    ),
                    Text(
                      //"价格(USDT)",
                      priceStr,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: HexColor("#777777"),
                      ),
                    ),
                    Text(
                      //"数量(HYN)卖盘",
                      S.of(context).kline_delegate_amount +
                          " " +
                          S.of(context).kline_delegate_sell,
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
                                      var depthPrice = buyEntity
                                              ?.depthEntity?.price
                                              .toString() ??
                                          "0";
                                      clickPrice(depthPrice);
                                      //print("[KLINE] 当前选中价格：${buyEntity?.depthEntity?.price?.toString() ?? "--"}");
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
                                    padding: EdgeInsets.only(
                                        left: index >= 9 ? 3 : 8),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      buyEntity?.depthEntity?.vol?.toString() ??
                                          "--",
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
                                        FormatUtil.clearScientificCounting(
                                                buyEntity
                                                    ?.depthEntity?.price) ??
                                            "--",
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
                                      clickPrice(sellEntity?.depthEntity?.price
                                              .toString() ??
                                          "0");
                                      //print("[KLINE] 当前选中价格：${sellEntity?.depthEntity?.price?.toString() ?? "--"}");
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
                                        FormatUtil.clearScientificCounting(
                                                sellEntity
                                                    ?.depthEntity?.price) ??
                                            "--",
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
                                      sellEntity?.depthEntity?.vol
                                              ?.toString() ??
                                          "--",
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
                                    padding: EdgeInsets.only(
                                        left: index >= 9 ? 3 : 8),
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
            itemCount: limitNum == 20
                ? max(buyChartList.length, sellChartList.length)
                : limitNum),
      ],
    ),
  );
}

dealDepthData(List<ExcDetailEntity> buyChartList,
    List<ExcDetailEntity> sellChartList, dynamic data,
    {var enable = true}) {
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
            entity.vol = double.parse(itemList[1].toString());
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
      if (current.vol > next.vol) {
        return current;
      }
      return next;
    });
  }

  // buy
  var buyList = deptList(data["buy"], "buy");
  if (buyList.isNotEmpty) {
    var defaultLength = buyList.length;
    if (enable && defaultLength > 5) {
      defaultLength = 5;
      buyList = buyList.sublist(0, defaultLength);
    }

    var max = maxDepthEntity(buyList);
    for (int index = 0; index < buyList.length; index++) {
      var buy = buyList[index];
      var right = 10 * buy.vol ~/ max.vol;
      var left = 10 - right;
      var entity = ExcDetailEntity(2, left, right, depthEntity: buy);
      buyChartList.add(entity);
    }
  }

  // sell
  var sellList = deptList(data["sell"], "sell");
  if (sellList.isNotEmpty) {
    var defaultLength = sellList.length;
    if (enable && defaultLength > 5) {
      defaultLength = 5;
      sellList = sellList.sublist(0, defaultLength);
    }
    var max = maxDepthEntity(sellList);
    for (int index = 0; index < sellList.length; index++) {
      var sell = sellList[index];
      var left = 10 * sell.vol ~/ max.vol;
      var right = 10 - left;
      var entity = ExcDetailEntity(4, left, right, depthEntity: sell);
      sellChartList.add(entity);
    }
  }

//  print(
//      "[WS] --> _getDepthData,buyChartList.length:${buyChartList.length}, sellChartList.length:${sellChartList.length}");
}
