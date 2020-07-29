import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/exchange/model.dart';
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
import 'package:titan/src/pages/market/quote/kline_detail_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/custom_seekbar/custom_seekbar.dart';
import 'dart:math' as math;
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/order/exchange_active_order_list_page.dart';
import 'package:titan/src/widget/popup/bubble_widget.dart';
import 'package:titan/src/widget/popup/pop_route.dart';
import 'package:titan/src/widget/popup/pop_widget.dart';
import 'package:titan/src/pages/market/quote/kline_detail_page.dart';

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

  bool isLoading = false;
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
  StreamController<int> depthController = StreamController.broadcast();
  StreamController<Map> optionsController = StreamController.broadcast();
  StreamController<int> consignListController = StreamController.broadcast();
  String userTickChannel = "";
  String depthChannel;
  String tradeChannel;

//  List<Order> _currentOrders = List();
  ExchangeModel exchangeModel;
  String symbol;
  String marketCoin;
  MarketInfoEntity marketInfoEntity = MarketInfoEntity.defaultEntity(8, 8, 8, [1, 2, 3, 4]);
  List<ExcDetailEntity> _buyChartList = [];
  List<ExcDetailEntity> _sailChartList = [];
  int selectDepthNum = 1;
  String _realTimePrice = "--";
  double _realTimePricePercent = 0;

  @override
  void initState() {
    symbol = "hyn${widget.selectedCoin.toLowerCase()}";
    marketCoin = "HYN/${widget.selectedCoin.toUpperCase()}";
    exchangeDetailBloc.add(MarketInfoEvent(marketCoin));
    exchangeDetailBloc.add(DepthInfoEvent(symbol, selectDepthNum));
    super.initState();
  }

  @override
  void onCreated() {
    exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;

    _getChannelData();
    super.onCreated();
  }

  @override
  void didPopNext() {
    _getChannelData();
    consignListController.add(contrConsignTypeRefresh);
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    if (exchangeModel.isActiveAccount()) {
      BlocProvider.of(context).add(UnSubChannelEvent(channel: userTickChannel));
    }
    Application.routeObserver.unsubscribe(this);
    BlocProvider.of(context).add(UnSubChannelEvent(channel: depthChannel));
    BlocProvider.of(context).add(UnSubChannelEvent(channel: tradeChannel));

    optionsController.close();
    exchangeDetailBloc.close();
    super.dispose();
  }

  void _getChannelData() {
    if (exchangeModel.isActiveAccount()) {
      userTickChannel = SocketConfig.channelUserTick(exchangeModel.activeAccount.id, symbol);
      BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: userTickChannel));
    }
    depthChannel = SocketConfig.channelExchangeDepth(symbol, selectDepthNum);
    BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: depthChannel));

    tradeChannel = SocketConfig.channelTradeDetail(symbol);
    BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: tradeChannel));
  }

  @override
  Widget build(BuildContext context) {
    _realTimePrice = MarketInheritedModel.of(context).getRealTimePrice(symbol);
    _realTimePricePercent = MarketInheritedModel.of(context).getRealTimePricePercent(symbol);

    return Scaffold(
      body: BlocListener<SocketBloc, SocketState>(
        bloc: BlocProvider.of<SocketBloc>(context),
        listener: (ctx, state) {
          if (state is ChannelExchangeDepthState) {
            _buyChartList.clear();
            _sailChartList.clear();
            dealDepthData(_buyChartList, _sailChartList, state.response, isReplace: false);
            depthController.add(contrDepthTypeRefresh);
          }
        },
        child: BlocListener<ExchangeDetailBloc, AllPageState>(
          bloc: exchangeDetailBloc,
          listener: (ctx, state) {
            if (state is ExchangeMarketInfoState) {
              marketInfoEntity = state.marketInfoEntity;
            } else if (state is DepthInfoState) {
              _buyChartList.clear();
              _sailChartList.clear();
              dealDepthData(_buyChartList, _sailChartList, state.depthData);
              depthController.add(contrDepthTypeRefresh);
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
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _depthWidget(),
                  _exchangeOptionsWidget(),
                  _consignListWidget()
                ],
              )),
            ),
          ],
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
                padding: EdgeInsets.all(2.0),
                child: Text(
                  _realTimePricePercent == 0 ? "--" : (_realTimePricePercent >= 0 ? "+" : "-") + FormatUtil.truncateDoubleNum(_realTimePricePercent * 100,2) + "%",
                  style: TextStyle(
                    color: _realTimePricePercent >= 0 ? HexColor("#53AE86") : HexColor("#CC5858"),
                    fontSize: 13.0,
                  ),
                ),
                decoration: BoxDecoration(
                    color: isBuy ? HexColor("#EBF8F2") : HexColor("#F9EFEF"), borderRadius: BorderRadius.circular(4.0)),
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
                          "深度$selectDepthNum位",
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
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => KLineDetailPage(symbol: symbol, symbolName: widget.selectedCoin,)));
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

  Widget _depthWidget(){
    return StreamBuilder(
        stream: depthController.stream,
        builder: (context, optionType) {
          return Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(width: 14,),
                  Text(_realTimePrice,style:TextStyle(fontSize: 18,color: DefaultColors.color53ae86)),
                  SizedBox(width: 6,),
                  Padding(
                    padding: const EdgeInsets.only(bottom:3.0),
                    child: Text("≈63027.47 CNY",style:TextStyle(fontSize: 10,color: DefaultColors.color777)),
                  ),
                ],
              ),
              delegationListView(_buyChartList, _sailChartList, limitNum: 5),
            ],
          );
        });
  }

  updateTotalView(Decimal totalPrice) {
    totalPriceStr = FormatUtil.truncateDecimalNum(totalPrice,marketInfoEntity.turnoverPrecision);
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
                                "深度小数位",
                                style: TextStyle(fontSize: 12, color: DefaultColors.color333),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SizedBox(
                      width: 100,
                      height: 29.5,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          changeDepthLevel(index);
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
                              child: Text("$index位", style: TextStyle(fontSize: 12, color: DefaultColors.color999)),
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
          if (optionKey == contrOptionsTypeBuy) {
            isBuy = true;
          } else if (optionKey == contrOptionsTypeSell) {
            isBuy = false;
          } else if (optionKey == contrOptionsTypeLimit) {
            isLimit = true;
          } else if (optionKey == contrOptionsTypeMarket) {
            isLimit = false;
          } else if (optionKey == contrOptionsTypePrice) {
            var totalPrice = currentPrice * currentNum;
            updateTotalView(totalPrice);

            currentPriceStr = currentPrice.toString();
          } else if (optionKey == contrOptionsTypePricePreError) {
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentPriceStr.length));
          } else if (optionKey == contrOptionsTypePriceAdd) {
            var preNum = math.pow(10, marketInfoEntity.pricePrecision);
            currentPrice += Decimal.parse((1 / preNum).toString());
            var totalPrice = currentPrice * currentNum;
            updateTotalView(totalPrice);

            currentPriceStr = FormatUtil.truncateDecimalNum(currentPrice,marketInfoEntity.pricePrecision);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentPriceStr.length));
          } else if (optionKey == contrOptionsTypePriceDecrease) {
            var preNum = math.pow(10, marketInfoEntity.pricePrecision);
            currentPrice -= Decimal.parse((1 / preNum).toString());
            var totalPrice = currentPrice * currentNum;
            updateTotalView(totalPrice);

            currentPriceStr = FormatUtil.truncateDecimalNum(currentPrice,marketInfoEntity.pricePrecision);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: '$currentPriceStr'.length));
          } else if (optionKey == contrOptionsTypeNum) {
            var totalPrice = currentPrice * currentNum;
            updateTotalView(totalPrice);

            currentNumStr = FormatUtil.truncateDecimalNum(currentNum,marketInfoEntity.amountPrecision);
          } else if (optionKey == contrOptionsTypeNumPercent) {
            if (exchangeModel.isActiveAccount()) {
              if (isBuy) {
                currentNum = getValidNum() * Decimal.parse(optionValue) / currentPrice;
              } else {
                currentNum = getValidNum() * Decimal.parse(optionValue);
              }
              var totalPrice = currentPrice * currentNum;
              updateTotalView(totalPrice);

              currentNumStr = FormatUtil.truncateDecimalNum(currentNum,marketInfoEntity.amountPrecision);
              numEditController.text = currentNumStr;
              numEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentNumStr.length));
            }
          } else if (optionKey == contrOptionsTypeNumPreError) {
            numEditController.text = currentNumStr;
            numEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentNumStr.length));
          } else if(optionKey == contrOptionsTypeTotalPrice){
            totalPriceStr = optionValue;
            if(currentPrice != Decimal.fromInt(0)){
              currentNum = Decimal.parse(optionValue) / currentPrice;
              currentNumStr = FormatUtil.truncateDecimalNum(currentNum,marketInfoEntity.amountPrecision);
              numEditController.text = currentNumStr;
              numEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentNumStr.length));
            }
          } else if(optionKey == contrOptionsTypeTotalPriceError){
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
                          child: Text('买入'),
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
                          child: Text('卖出'),
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
                    height: 36,
                    margin: EdgeInsets.only(top: 10, bottom: 2),
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "价格",
                          style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextField(
                            controller: priceEditController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                            decoration: new InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 12.0),
                              border: InputBorder.none,
                              hintStyle: TextStyles.textCaaaS14,
                            ),
                            onChanged: (price) {
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
                        Container(
                          width: 1,
                          color: DefaultColors.colord0d0d0,
                        ),
                        InkWell(
                          onTap: () {
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
                        "数量",
                        style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: numEditController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 12.0),
                            border: InputBorder.none,
                            hintStyle: TextStyles.textCaaaS14,
                          ),
                          onChanged: (number) {
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
                              if (isBuy && currentPrice == 0) {
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
                              if (isBuy && currentPrice == 0) {
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
                              if (isBuy && currentPrice == 0) {
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
                        "金额",
                        style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          controller: totalEditController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 12.0),
                            border: InputBorder.none,
                            hintStyle: TextStyles.textCaaaS14,
                          ),
                          onChanged: (turnover) {
                            if (turnover.contains(".")) {
                              var priceAfter = turnover.split(".")[1];
                              if (priceAfter.length <= marketInfoEntity.turnoverPrecision) {
                                optionsController.add({contrOptionsTypeTotalPrice: turnover});
                              } else {
                                optionsController.add({contrOptionsTypeTotalPriceError: ""});
                              }
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
                    "可用  ${getValidNum() == 0 ? "~" : getValidNum()}  ${isBuy ? widget.selectedCoin.toUpperCase() : "HYN"}",
                    style: TextStyle(color: DefaultColors.color999, fontSize: 10),
                  ),
                ),
                Container(
                  height: 36,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: isBuy ? DefaultColors.color53ae86 : DefaultColors.colorcc5858,
                  ),
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
                      ),
                      padding: const EdgeInsets.all(0.0),
                      child: Text(exchangeModel.isActiveAccount() ? isBuy ? "买入" : "卖出" : "请登录",
                          style: TextStyle(
                            fontSize: 14,
                            color: isLoading ? DefaultColors.color999 : Colors.white,
                          )),
                      onPressed: isLoading
                          ? null
                          : () async {
                              isLoading = true;
                              optionsController.add({contrOptionsTypeRefresh: ""});

                              await buyAction();
                              isLoading = false;
                              optionsController.add({contrOptionsTypeRefresh: ""});
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
                        "当前委托",
                        style: TextStyle(fontSize: 16, color: DefaultColors.color333),
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
                            child: Text("全部",
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
            if (exchangeModel.isActiveAccount()) ExchangeActiveOrderListPage(marketCoin)
          ],
        );
      },
    );
  }

  void changeDepthLevel(int newLevel) {
    selectDepthNum = newLevel;
    exchangeDetailBloc.add(DepthInfoEvent(symbol, selectDepthNum));
    BlocProvider.of<SocketBloc>(context).add(UnSubChannelEvent(channel: depthChannel));
    depthChannel = SocketConfig.channelExchangeDepth(symbol, selectDepthNum);
    BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: depthChannel));
    depthController.add(contrDepthTypeRefresh);
  }

  void buyAction() {
    if (exchangeModel.isActiveAccount()) {
      if (isLimit && currentPriceStr.isEmpty) {
        Fluttertoast.showToast(msg: "价格不能为0");
        return;
      }
      if (currentNumStr.isEmpty) {
        Fluttertoast.showToast(msg: "数量不能为0");
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
