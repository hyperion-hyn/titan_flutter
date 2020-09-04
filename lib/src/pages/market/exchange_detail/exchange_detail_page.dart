import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/exchange/model.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/market_info_entity.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:titan/src/pages/market/order/item_order.dart';
import 'package:titan/src/pages/market/order/exchange_order_mangement_page.dart';
import 'package:titan/src/pages/market/k_line/kline_detail_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/custom_seekbar/custom_seekbar.dart';
import 'dart:math' as math;
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/order/exchange_active_order_list_page.dart';
import 'package:titan/src/widget/popup/bubble_widget.dart';
import 'package:titan/src/widget/popup/pop_route.dart';
import 'package:titan/src/widget/popup/pop_widget.dart';

import 'bloc/exchange_detail_bloc.dart';

class ExchangeDetailPage extends StatefulWidget {
//  final String leftSymbol;
//  final String rightSymbol;
  var selectedCoin = 'USDT';
  var exchangeType = ExchangeType.SELL;

  ExchangeDetailPage({this.selectedCoin, this.exchangeType});

  @override
  State<StatefulWidget> createState() {
    return ExchangeDetailPageState();
  }
}

class ExchangeDetailPageState extends BaseState<ExchangeDetailPage> with RouteAware {
  ExchangeDetailBloc exchangeDetailBloc = ExchangeDetailBloc();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  SocketBloc _socketBloc;

  bool isOrderActionLoading = false;
  bool isBuy = true;
  bool isLimit = true;
  Decimal currentPrice = Decimal.fromInt(0);
  Decimal currentNum = Decimal.fromInt(0);
  String currentPriceStr = "";
  String currentNumStr = "";
  String totalPriceStr = "";

  TextEditingController priceEditController = new TextEditingController();
  TextEditingController numEditController = new TextEditingController();
  TextEditingController totalEditController = new TextEditingController();

  final int contrOptionsTypeBuy = 0;
  final int contrOptionsTypeSell = 1;
  final int contrOptionsTypeLimit = 2;
  final int contrOptionsTypeMarket = 3;
  final int contrOptionsTypePrice = 4;
  final int contrOptionsTypePriceAdd = 5;
  final int contrOptionsTypePriceDecrease = 6;
  final int contrOptionsTypePricePreError = 7;
  final int contrOptionsTypeNum = 8;
  final int contrOptionsTypeNumPercent = 9;
  final int contrOptionsTypeNumPreError = 10;
  final int contrOptionsTypeTotalPrice = 11;
  final int contrOptionsTypeTotalPriceError = 12;
  final int contrOptionsTypeRefresh = 13;

  final int contrConsignTypeRefresh = 14;

  final int contrDepthTypeRefresh = 15;
  List<ExcDetailEntity> _buyChartList = [];
  List<ExcDetailEntity> _sailChartList = [];
  int selectDepthNum = 4;

  List<Order> _activeOrders = List();
  int consignPageSize = 1;
  bool consignIsLoading = true;

  StreamController<Map> optionsController = StreamController.broadcast();
  StreamController<int> depthController = StreamController.broadcast();
  StreamController<int> consignListController = StreamController.broadcast();

  String userTickChannel = "";
  String depthChannel;
  String tradeChannel;

//  List<Order> _currentOrders = List();
  ExchangeModel exchangeModel;
  String symbol;
  String marketCoin;
  MarketInfoEntity marketInfoEntity = MarketInfoEntity.defaultEntity(8, 8, 8, 1000000, 10, [1, 2, 3, 4]);
  bool beforeJumpNoLogin = true;

  String _realTimePrice = "--";
  String _realTimeQuotePrice = "--";
  ActiveQuoteVoAndSign selectQuote;
  double _realTimePricePercent = 0;

  @override
  void initState() {
    symbol = "hyn${widget.selectedCoin.toLowerCase()}";
    marketCoin = "HYN/${widget.selectedCoin.toUpperCase()}";
    isBuy = (widget.exchangeType == ExchangeType.BUY);
    exchangeDetailBloc.add(MarketInfoEvent(marketCoin));
    super.initState();
  }

  @override
  void onCreated() {
    _socketBloc = BlocProvider.of<SocketBloc>(context);
    exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;
    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    _getExchangelData();
    super.onCreated();
  }

  @override
  void didPopNext() {
    isOrderActionLoading = false;

    _getExchangelData();
    super.didPopNext();
  }

  @override
  void dispose() {
    if (exchangeModel.isActiveAccount()) {
      _socketBloc.add(UnSubChannelEvent(channel: userTickChannel));
    }
    Application.routeObserver.unsubscribe(this);
    _socketBloc.add(UnSubChannelEvent(channel: depthChannel));
    _socketBloc.add(UnSubChannelEvent(channel: tradeChannel));

    optionsController.close();
    exchangeDetailBloc.close();
    _loadDataBloc.close();
    super.dispose();
  }

  void _getExchangelData() async {
    if (exchangeModel.isActiveAccount()) {
      beforeJumpNoLogin = false;
      userTickChannel = SocketConfig.channelUserTick(exchangeModel.activeAccount.id, symbol);
      _socketBloc.add(SubChannelEvent(channel: userTickChannel));
    } else {
      beforeJumpNoLogin = true;
    }

    tradeChannel = SocketConfig.channelTradeDetail(symbol);
    _socketBloc.add(SubChannelEvent(channel: tradeChannel));

    _loadDataBloc.add(LoadingEvent());
    consignPageSize = 1;
    try {
      await loadConsignList(marketCoin, consignPageSize, _activeOrders);
      consignListController.add(contrConsignTypeRefresh);
    }catch(error){
    }
    _loadDataBloc.add(RefreshSuccessEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SocketBloc, SocketState>(
        bloc: _socketBloc,
        listener: (ctx, state) {
          bool isRefresh = consignListSocket(state, _activeOrders, true);
          if(isRefresh){
            _loadDataBloc.add(LoadingMoreSuccessEvent());
            consignListController.add(contrConsignTypeRefresh);
          }
          if (state is ChannelExchangeDepthState) {
            _buyChartList.clear();
            _sailChartList.clear();
            dealDepthData(_buyChartList, _sailChartList, state.response);
            depthController.add(contrDepthTypeRefresh);
          }
        },
        child: BlocListener<ExchangeDetailBloc, AllPageState>(
          bloc: exchangeDetailBloc,
          listener: (ctx, state) {
            if (state is ExchangeMarketInfoState) {
              if(state.marketInfoEntity != null) {
                marketInfoEntity = state.marketInfoEntity;
              }
              selectDepthNum = marketInfoEntity.depthPrecision[marketInfoEntity.depthPrecision.length - 1];
              exchangeDetailBloc.add(DepthInfoEvent(symbol, selectDepthNum));
            } else if (state is DepthInfoState) {
              _buyChartList.clear();
              _sailChartList.clear();
              dealDepthData(_buyChartList, _sailChartList, state.depthData);
              depthController.add(contrDepthTypeRefresh);

              depthChannel = SocketConfig.channelExchangeDepth(symbol, selectDepthNum);
              _socketBloc.add(SubChannelEvent(channel: depthChannel));
            } else if (state is OrderPutLimitState) {
              isOrderActionLoading = false;
              if (state.respMsg == null) {
                Fluttertoast.showToast(msg: "下单成功", gravity: ToastGravity.CENTER);
                currentPrice = Decimal.fromInt(0);
                currentNum = Decimal.fromInt(0);
                currentPriceStr = "";
                currentNumStr = "";
                totalPriceStr = "";
                priceEditController.text = "";
                numEditController.text = "";
                totalEditController.text = "";
              } else {
                Fluttertoast.showToast(msg: state.respMsg);
              }
              optionsController.add({contrOptionsTypeRefresh: ""});
            }
          },
          child: BlocBuilder<ExchangeDetailBloc, AllPageState>(
            bloc: exchangeDetailBloc,
            condition: (ctx, state) {
              if (state is ExchangeInitial) {
                return true;
              }
              return false;
            },
            builder: (BuildContext context, AllPageState state) {
              switch (state.runtimeType) {
                default:
                  return exchangePageView();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget exchangePageView() {
    _realTimePrice = MarketInheritedModel.of(context).getRealTimePrice(symbol);
    selectQuote = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.selectedCoin);
    _realTimeQuotePrice =
        FormatUtil.truncateDoubleNum(double.parse(_realTimePrice) * (selectQuote?.quoteVo?.price ?? 0), 2);
    _realTimePricePercent = MarketInheritedModel.of(context).getRealTimePricePercent(symbol);

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              _appBar(),
              Expanded(
                child: LoadDataContainer(
                  bloc: _loadDataBloc,
                  enablePullDown: false,
                  enablePullUp: exchangeModel.isActiveAccount(),
                  onLoadData: () {},
                  onLoadingMore: () async {
                    if (exchangeModel.isActiveAccount()) {
                      consignPageSize++;
                      await loadMoreConsignList(_loadDataBloc, marketCoin, consignPageSize, _activeOrders);
                      consignListController.add(contrConsignTypeRefresh);
                    } else {
                      _loadDataBloc.add(LoadingMoreSuccessEvent());
                    }
                  },
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[_depthWidget(), _exchangeOptionsWidget(), _consignListWidget()],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return StreamBuilder(
        stream: depthController.stream,
        builder: (context, optionType) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  marketCoin,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 3.0, bottom: 2, left: 2, right: 2),
                child: Text(
                  _realTimePricePercent == 0
                      ? "--"
                      : (_realTimePricePercent >= 0 ? "+" : "-") +
                          FormatUtil.truncateDoubleNum(_realTimePricePercent * 100, 2) +
                          "%",
                  style: TextStyle(
                    color: _realTimePricePercent >= 0 ? HexColor("#53AE86") : HexColor("#CC5858"),
                    fontSize: 10.0,
                  ),
                ),
                decoration: BoxDecoration(
                    color: _realTimePricePercent >= 0 ? HexColor("#EBF8F2") : HexColor("#F9EFEF"),
                    borderRadius: BorderRadius.circular(4.0)),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  showDepthView();
                },
                child: Container(
                  padding: EdgeInsets.only(top: 2.0, bottom: 2, left: 10, right: 10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                      borderRadius: BorderRadius.all(Radius.circular(2))),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0, right: 15),
                        child: Text(
                          S.of(context).depth_bit(selectDepthNum),
                          style: TextStyle(fontSize: 10, color: DefaultColors.color999),
                        ),
                      ),
                      Image.asset(
                        "res/drawable/ic_exchange_down_triangle.png",
                        width: 7,
                        height: 5,
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => KLineDetailPage(
                                symbol: symbol,
                                symbolName: widget.selectedCoin,
                              )));
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8, left: 20, right: 14),
                  child: Image.asset(
                    "res/drawable/ic_exchange_candle.png",
                    width: 13,
                    height: 16,
                  ),
                ),
              )
            ],
          );
        });
  }

  Widget _depthWidget() {
    return StreamBuilder(
        stream: depthController.stream,
        builder: (context, optionType) {
          return Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 14,
                  ),
                  Text(_realTimePrice,
                      style: TextStyle(
                          fontSize: 18,
                          color: _realTimePricePercent >= 0 ? DefaultColors.color53ae86 : DefaultColors.colorcc5858)),
                  SizedBox(
                    width: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: Text("≈$_realTimeQuotePrice CNY",
                        style: TextStyle(fontSize: 10, color: DefaultColors.color777)),
                  ),
                ],
              ),
              delegationListView(_buyChartList, _sailChartList, limitNum: 5, clickPrice: (depthPrice) {
                currentPrice = Decimal.parse(depthPrice);
                currentPriceStr = depthPrice;
                priceEditController.text = currentPriceStr;
                optionsController.add({contrOptionsTypePrice: ""});
              }),
            ],
          );
        });
  }

  updateTotalView() {
    if (currentPrice.toDouble() == 0 || currentNum.toDouble() == 0) {
      return;
    }
    var totalPrice = currentPrice * currentNum;
    totalPriceStr = FormatUtil.truncateDecimalNum(totalPrice, marketInfoEntity.turnoverPrecision);
    totalEditController.text = totalPriceStr;
    totalEditController.selection = TextSelection.fromPosition(TextPosition(offset: totalPriceStr.length));
  }

  Decimal getValidNum() {
    if (exchangeModel.isActiveAccount()) {
      if (isBuy) {
        return Decimal.parse(
            exchangeModel.activeAccount.assetList.getAsset(widget.selectedCoin.toUpperCase()).exchangeAvailable);
      } else {
        return Decimal.parse(exchangeModel.activeAccount?.assetList?.getAsset("HYN")?.exchangeAvailable);
      }
    } else {
      return Decimal.fromInt(0);
    }
  }

  String getInputPriceQuote(){
    if((selectQuote?.quoteVo?.price ?? 0) == 0 || currentPriceStr == ""
    || Decimal.parse(currentPriceStr) == Decimal.fromInt(0)){
      return "--";
    }
    var priceQuote = Decimal.parse(selectQuote.quoteVo.price.toString()) * Decimal.parse(currentPriceStr);
    return FormatUtil.truncateDecimalNum(priceQuote, marketInfoEntity.pricePrecision);
  }

  showDepthView() {
    return Navigator.push(
      context,
      PopRoute(
        child: Popup(
          child: BubbleWidget(100.0, 166.0, Colors.white, BubbleArrowDirection.top,
              length: 55,
              innerPadding: 0.0,
              child: Container(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (subContext, index) {
                    if (index == 0) {
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                S.of(context).depth_decimal_places,
                                style: TextStyle(fontSize: 12, color: DefaultColors.color333),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    var depthIndex = marketInfoEntity.depthPrecision[index - 1];
                    return SizedBox(
                      width: 100,
                      height: 29.5,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          changeDepthLevel(depthIndex);
                          Navigator.of(context).pop();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Divider(
                              height: 0.5,
                              color: DefaultColors.colorf2f2f2,
                              indent: 13,
                              endIndent: 13,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child:
                                  Text(S.of(context).num_decimal_places(depthIndex), style: TextStyle(fontSize: 12, color: DefaultColors.color999)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: marketInfoEntity.depthPrecision.length + 1,
                ),
              )),
          left: 238,
          top: 66,
        ),
      ),
    );
  }

  Widget _exchangeOptionsWidget() {
    return StreamBuilder<Map>(
        stream: optionsController.stream,
        builder: (context, optionType) {
          Map optionData = optionType.data;
          var optionKey = optionData?.keys?.elementAt(0) ?? -1;
          var optionValue = optionData?.values?.elementAt(0) ?? "";
          if (optionKey != contrOptionsTypeRefresh) {
            optionsController.add({contrOptionsTypeRefresh: ""});
          }
          if (optionKey == contrOptionsTypeBuy) {
            isBuy = true;
          } else if (optionKey == contrOptionsTypeSell) {
            isBuy = false;
          } else if (optionKey == contrOptionsTypeLimit) {
            isLimit = true;
          } else if (optionKey == contrOptionsTypeMarket) {
            isLimit = false;
          } else if (optionKey == contrOptionsTypePrice) {
            updateTotalView();

            currentPriceStr = currentPrice.toString();
          } else if (optionKey == contrOptionsTypePricePreError) {
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentPriceStr.length));
          } else if (optionKey == contrOptionsTypePriceAdd) {
            var preNum = math.pow(10, marketInfoEntity.pricePrecision);
            currentPrice += Decimal.parse((1 / preNum).toString());
            updateTotalView();

            currentPriceStr = FormatUtil.truncateDecimalNum(currentPrice, marketInfoEntity.pricePrecision);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentPriceStr.length));
          } else if (optionKey == contrOptionsTypePriceDecrease) {
            var preNum = math.pow(10, marketInfoEntity.pricePrecision);
            currentPrice -= Decimal.parse((1 / preNum).toString());
            updateTotalView();

            currentPriceStr = FormatUtil.truncateDecimalNum(currentPrice, marketInfoEntity.pricePrecision);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: '$currentPriceStr'.length));
          } else if (optionKey == contrOptionsTypeNum) {
            updateTotalView();

            currentNumStr = FormatUtil.truncateDecimalNum(currentNum, marketInfoEntity.amountPrecision);
          } else if (optionKey == contrOptionsTypeNumPercent) {
            if (exchangeModel.isActiveAccount()) {
              if (isBuy) {
                currentNum = currentPrice.toString() == "0"
                    ? currentNum
                    : getValidNum() * Decimal.parse(optionValue) / currentPrice;
              } else {
                currentNum = getValidNum() * Decimal.parse(optionValue);
              }
              updateTotalView();

              currentNumStr = FormatUtil.truncateDecimalNum(currentNum, marketInfoEntity.amountPrecision);
              numEditController.text = currentNumStr;
              numEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentNumStr.length));
            }
          } else if (optionKey == contrOptionsTypeNumPreError) {
            numEditController.text = currentNumStr;
            numEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentNumStr.length));
          } else if (optionKey == contrOptionsTypeTotalPrice) {
            totalPriceStr = optionValue;
            if (currentPrice != Decimal.fromInt(0) && optionValue != "") {
              currentNum = Decimal.parse(optionValue) / currentPrice;
              currentNumStr = FormatUtil.truncateDecimalNum(currentNum, marketInfoEntity.amountPrecision);
              numEditController.text = currentNumStr;
              numEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentNumStr.length));
            }
          } else if (optionKey == contrOptionsTypeTotalPriceError) {
            totalEditController.text = totalPriceStr;
            totalEditController.selection = TextSelection.fromPosition(TextPosition(offset: totalPriceStr.length));
          } else if (optionKey == contrOptionsTypeRefresh) {}
          return Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 16, left: 14, right: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () {
                          optionsController.add({contrOptionsTypeBuy: ""});
                        },
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                                image: AssetImage(isBuy
                                    ? "res/drawable/ic_exchange_bg_left_buy_select.png"
                                    : "res/drawable/ic_exchange_bg_left_buy.png"),
                                fit: BoxFit.fitWidth),
                          ),
                          alignment: Alignment.center,
                          child: Text(S.of(context).buy,
                              style: TextStyle(fontSize: 14, color: isBuy ? Colors.white : DefaultColors.color999)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () {
                          optionsController.add({contrOptionsTypeSell: ""});
                        },
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                                image: AssetImage(isBuy
                                    ? "res/drawable/ic_exchange_bg_right_sell.png"
                                    : "res/drawable/ic_exchange_bg_right_sell_select.png"),
                                fit: BoxFit.fitWidth),
                          ),
                          alignment: Alignment.center,
                          child: Text(S.of(context).sale,
                              style: TextStyle(fontSize: 14, color: isBuy ? DefaultColors.color999 : Colors.white)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: SizedBox(),
                      /*child: Container(
                          height: 28,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                              borderRadius: BorderRadius.all(Radius.circular(3))),
                          child: new DropdownButtonHideUnderline(
                              child: new DropdownButton(
                            icon: Image.asset(
                              "res/drawable/ic_exchange_down_triangle.png",
                              width: 10,
                            ),
                            items: [
                              new DropdownMenuItem(
                                child: new Text('限价委托'),
                                value: contrOptionsTypeLimit,
                              ),
                              new DropdownMenuItem(
                                child: new Text('市价委托'),
                                value: contrOptionsTypeMarket,
                              ),
                            ],
                            hint: new Text('请选择'),
                            onChanged: (value) {
                              optionsController.add(value);
                            },
                            isExpanded: true,
                            value: isLimit ? contrOptionsTypeLimit : contrOptionsTypeMarket,
                            style: new TextStyle(
                              color: DefaultColors.color333,
                              fontSize: 14,
                            ),
                          ))),*/
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    margin: EdgeInsets.only(top: 10, bottom: 2),
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom:currentPriceStr != "0" && currentPriceStr != "" ? 16.0 : 0),
                          child: Text(
                            S.of(context).price,
                            style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 36,
                                child: TextField(
                                  controller: priceEditController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                                  decoration: new InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 12.0),
                                    border: InputBorder.none,
                                    hintStyle: TextStyles.textCaaaS14,
                                  ),
                                  onChanged: (price) {
                                    if (price.contains("-")) {
                                      return;
                                    }
                                    if (price.contains(".")) {
                                      var priceAfter = price.split(".")[1];
                                      if (priceAfter.length <= marketInfoEntity.pricePrecision) {
                                        currentPrice = Decimal.parse(price);
                                        optionsController.add({contrOptionsTypePrice: ""});
                                      } else {
                                        optionsController.add({contrOptionsTypePricePreError: ""});
                                      }
                                    } else {
                                      if (price.length == 0) {
                                        currentPrice = Decimal.fromInt(0);
                                      } else {
                                        currentPrice = Decimal.parse(price);
                                      }
                                      optionsController.add({contrOptionsTypePrice: ""});
                                    }
                                  },
                                ),
                              ),
                              if(currentPriceStr != "0" && currentPriceStr != "")
                                Padding(
                                  padding: const EdgeInsets.only(bottom:4.0),
                                  child: Text("≈${getInputPriceQuote()} CNY",style: TextStyle(fontSize: 10,color: DefaultColors.color999),),
                                )
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          color: DefaultColors.colord0d0d0,
                        ),
                        InkWell(
                          onTap: () {
                            if (currentPrice.toDouble() == 0) {
                              return;
                            }
                            optionsController.add({contrOptionsTypePriceDecrease: ""});
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 4, left: 17, right: 17),
                            child: Text(
                              "-",
                              style: TextStyle(fontSize: 21, color: DefaultColors.color999),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: DefaultColors.colord0d0d0,
                        ),
                        InkWell(
                            onTap: () {
                              optionsController.add({contrOptionsTypePriceAdd: ""});
                            },
                            child: Padding(
                                padding: EdgeInsets.only(top: 7, bottom: 7, left: 17, right: 17),
                                child: Text("+", style: TextStyle(color: DefaultColors.color999)))),
                      ],
                    )),
                Container(
                  height: 36,
                  margin: EdgeInsets.only(top: 10, bottom: 2),
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                  child: Row(
                    children: <Widget>[
                      Text(
                        S.of(context).count,
                        style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: numEditController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 12.0),
                            border: InputBorder.none,
                            hintStyle: TextStyles.textCaaaS14,
                          ),
                          onChanged: (number) {
                            if (number.contains("-")) {
                              return;
                            }
                            if (number.contains(".")) {
                              var priceAfter = number.split(".")[1];
                              if (priceAfter.length <= marketInfoEntity.amountPrecision) {
                                currentNum = Decimal.parse(number);
                                optionsController.add({contrOptionsTypeNum: ""});
                              } else {
                                optionsController.add({contrOptionsTypeNumPreError: ""});
                              }
                            } else {
                              if (number.length == 0) {
                                currentNum = Decimal.fromInt(0);
                              } else {
                                currentNum = Decimal.parse(number);
                              }
                              optionsController.add({contrOptionsTypeNum: ""});
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: FlatButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              if (isBuy && currentPrice == Decimal.fromInt(0)) {
                                return;
                              }
                              optionsController.add({contrOptionsTypeNumPercent: "0.25"});
                            },
                            child: Text(
                              "25%",
                              style: TextStyle(fontSize: 10, color: DefaultColors.color999),
                            )),
                      ),
                      SizedBox(
                        width: 36,
                        child: FlatButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              if (isBuy && currentPrice == Decimal.fromInt(0)) {
                                return;
                              }
                              optionsController.add({contrOptionsTypeNumPercent: "0.5"});
                            },
                            child: Text("50%", style: TextStyle(fontSize: 10, color: DefaultColors.color999))),
                      ),
                      SizedBox(
                        width: 36,
                        child: FlatButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              if (isBuy && currentPrice == Decimal.fromInt(0)) {
                                return;
                              }
                              optionsController.add({contrOptionsTypeNumPercent: "1"});
                            },
                            child: Text(
                              "100%",
                              style: TextStyle(fontSize: 10, color: DefaultColors.color999),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  margin: EdgeInsets.only(top: 10, bottom: 2),
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                  child: Row(
                    children: <Widget>[
                      Text(
                        S.of(context).amount,
                        style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: totalEditController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 12.0),
                            border: InputBorder.none,
                            hintStyle: TextStyles.textCaaaS14,
                          ),
                          onChanged: (turnover) {
                            if (turnover.contains("-")) {
                              return;
                            }
                            if (turnover.contains(".")) {
                              var priceAfter = turnover.split(".")[1];
                              if (priceAfter.length <= marketInfoEntity.turnoverPrecision) {
                                optionsController.add({contrOptionsTypeTotalPrice: turnover});
                              } else {
                                optionsController.add({contrOptionsTypeTotalPriceError: ""});
                              }
                            } else {
                              optionsController.add({contrOptionsTypeTotalPrice: turnover});
                            }
                          },
                        ),
                      ),
                      Text(
                        "${widget.selectedCoin.toUpperCase()}",
                        style: TextStyle(fontSize: 14, color: DefaultColors.color777),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Text(
                    "${S.of(context).available}  ${getValidNum() == 0 ? "~" : getValidNum()}  ${isBuy ? widget.selectedCoin.toUpperCase() : "HYN"}",
                    style: TextStyle(color: DefaultColors.color999, fontSize: 10),
                  ),
                ),
                Container(
                  height: 36,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: isOrderActionLoading
                        ? Color(0xffDEDEDE)
                        : isBuy ? DefaultColors.color53ae86 : DefaultColors.colorcc5858,
                  ),
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
                      ),
                      padding: const EdgeInsets.all(0.0),
                      child: Text(exchangeModel.isActiveAccount() ? isBuy ? "${S.of(context).buy}" : "${S.of(context).sale}" : S.of(context).login_please,
                          style: TextStyle(
                            fontSize: 14,
                            color: isOrderActionLoading ? DefaultColors.color999 : Colors.white,
                          )),
                      onPressed: isOrderActionLoading
                          ? null
                          : () {
                              isOrderActionLoading = true;
                              optionsController.add({contrOptionsTypeRefresh: ""});

                              buyAction();
                            }),
                )
              ],
            ),
          );
        });
  }

  Widget _consignListWidget() {
    return StreamBuilder<int>(
      stream: consignListController.stream,
      builder: (context, optionType) {
        if (optionType.data == contrConsignTypeRefresh) {}
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 13.0, bottom: 11, left: 13, right: 13),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        S.of(context).current_commission,
                        style: TextStyle(fontSize: 16, color: DefaultColors.color333, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Image.asset(
                              "res/drawable/ic_exhange_all_consign.png",
                              width: 12,
                              height: 12,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          InkWell(
                            child: Text("${S.of(context).all}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: DefaultColors.color999,
                                )),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ExchangeOrderManagementPage(
                                            marketCoin,
                                          )));
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 11,
                  ),
                  Divider(
                    height: 1,
                  )
                ],
              ),
            ),
            if (_activeOrders.length == 0) orderListEmpty(context),
            if (_activeOrders.length > 0) orderListWidget(context, marketCoin, consignIsLoading, _activeOrders)
          ],
        );
      },
    );
  }

  void changeDepthLevel(int newLevel) {
    selectDepthNum = newLevel;
    exchangeDetailBloc.add(DepthInfoEvent(symbol, selectDepthNum));
    _socketBloc.add(UnSubChannelEvent(channel: depthChannel));
    depthChannel = SocketConfig.channelExchangeDepth(symbol, selectDepthNum);
    _socketBloc.add(SubChannelEvent(channel: depthChannel));
    depthController.add(contrDepthTypeRefresh);
  }

  void buyAction() {
    if (exchangeModel.isActiveAccount()) {
      if (currentPriceStr.isEmpty || double.parse(currentPriceStr) == 0) {
        Fluttertoast.showToast(msg: S.of(context).input_price_please);
        isOrderActionLoading = false;
        optionsController.add({contrOptionsTypeRefresh: ""});
        return;
      }
      if (currentNumStr.isEmpty || double.parse(currentNumStr) == 0) {
        Fluttertoast.showToast(msg: S.of(context).input_num_please);
        isOrderActionLoading = false;
        optionsController.add({contrOptionsTypeRefresh: ""});
        return;
      }
      if(marketInfoEntity.amountMin > Decimal.parse(currentNumStr).toDouble()){
        Fluttertoast.showToast(msg: "${S.of(context).each}${isBuy?"${S.of(context).buy}":"${S.of(context).sale}"}${S.of(context).no_less_than}${marketInfoEntity.amountMin}HYN");
        isOrderActionLoading = false;
        optionsController.add({contrOptionsTypeRefresh: ""});
        return;
      }
      if(marketInfoEntity.amountMax < Decimal.parse(currentNumStr).toDouble()){
        Fluttertoast.showToast(msg: "${S.of(context).each}${isBuy?"${S.of(context).buy}":"${S.of(context).sale}"}${S.of(context).no_more_than}${marketInfoEntity.amountMax}HYN");
        isOrderActionLoading = false;
        optionsController.add({contrOptionsTypeRefresh: ""});
        return;
      }
      if ((isBuy && Decimal.parse(totalPriceStr) > getValidNum()) ||
          (!isBuy && Decimal.parse(currentNumStr) > getValidNum())) {
        Fluttertoast.showToast(msg: S.of(context).insufficient_balance);
        isOrderActionLoading = false;
        optionsController.add({contrOptionsTypeRefresh: ""});
        return;
      }
      var exchangeType = isBuy ? ExchangeType.BUY : ExchangeType.SELL;
      if (isLimit) {
        exchangeDetailBloc.add(LimitExchangeEvent(marketCoin, exchangeType, currentPriceStr, currentNumStr));
      } else {
        exchangeDetailBloc.add(MarketExchangeEvent(marketCoin, exchangeType, currentNumStr));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
    }
  }
}
