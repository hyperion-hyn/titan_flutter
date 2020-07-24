import 'dart:async';

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
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/custom_seekbar/custom_seekbar.dart';
import 'dart:math' as math;
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';

import 'bloc/exchange_detail_bloc.dart';

class ExchangeDetailPage extends StatefulWidget {
//  final String leftSymbol;
//  final String rightSymbol;
  var selectedCoin = 'usdt';
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
  double currentPrice = 0;
  double currentNum = 0;
  String currentPriceStr = "";
  String totalPriceStr = "";
  String currentNumStr = "";

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
  final int contrOptionsTypePricePreError = 9;
  final int contrOptionsTypeNum = 7;
  final int contrOptionsTypeNumPercent = 11;
  final int contrOptionsTypeNumPreError = 10;
  final int contrOptionsTypeRefresh = 8;

  final int contrConsignTypeRefresh = 11;
  StreamController<Map> optionsController = StreamController.broadcast();
  StreamController<int> consignListController = StreamController.broadcast();
  String userTickChannel = "";
  String depthChannel;
  List<Order> _currentOrders = List();
  ExchangeModel exchangeModel;
  String symbol;
  String marketCoin;
  MarketInfoEntity marketInfoEntity =
  MarketInfoEntity.defaultEntity(8, 8, 8, [1, 2, 3, 4, 5]);
  List<ExcDetailEntity> buyChartList = [];
  List<ExcDetailEntity> sailChartList = [];

  @override
  void initState() {
//    symbol = "hyn${widget.rightSymbol}";
    print("!!!111${widget.selectedCoin}");
    symbol = "hyn${widget.selectedCoin.toLowerCase()}";
    marketCoin = "HYN/${widget.selectedCoin.toUpperCase()}";
    print("!!!111222${widget.selectedCoin}");
    exchangeDetailBloc.add(MarketInfoEvent(marketCoin));

    buyChartList.add(ExcDetailEntity(2, 6, 4));
    buyChartList.add(ExcDetailEntity(2, 6, 4));
    buyChartList.add(ExcDetailEntity(2, 6, 4));
    buyChartList.add(ExcDetailEntity(2, 5, 5));
    buyChartList.add(ExcDetailEntity(2, 4, 6));
    buyChartList.add(ExcDetailEntity(2, 3, 7));

    sailChartList.add(ExcDetailEntity(4, 4, 6));
    sailChartList.add(ExcDetailEntity(4, 4, 6));
    sailChartList.add(ExcDetailEntity(4, 4, 6));
    sailChartList.add(ExcDetailEntity(4, 5, 5));
    sailChartList.add(ExcDetailEntity(4, 6, 4));
    sailChartList.add(ExcDetailEntity(4, 7, 3));

    super.initState();
  }

  @override
  void onCreated() {
    getAccountData();

    depthChannel = SocketConfig.channelExchangeDepth(symbol, 1);
    BlocProvider.of<SocketBloc>(context)
        .add(SubChannelEvent(channel: depthChannel));
    super.onCreated();
  }

  @override
  void didPopNext() {
    getAccountData();
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

    optionsController.close();
    exchangeDetailBloc.close();
    super.dispose();
  }

  void getAccountData() {
    exchangeModel = ExchangeInheritedModel
        .of(context)
        .exchangeModel;
    if (exchangeModel.isActiveAccount()) {
      userTickChannel = SocketConfig.channelUserTick(exchangeModel.activeAccount.id, symbol);
      BlocProvider.of<SocketBloc>(context).add(SubChannelEvent(channel: userTickChannel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SocketBloc, SocketState>(
        bloc: BlocProvider.of<SocketBloc>(context),
        listener: (ctx, state) {
          if (state is ChannelUserTickState) {
            var temOrders = List<Order>();
            state.response.forEach((entity) => {
            if ((entity as List<dynamic>).length >= 7 && (entity[2] == 0 || entity[2] == 1)){
              temOrders.add(Order.fromSocket(entity))}
            });

            if (temOrders.length > 0) {
              print("!!!!!!!order= ${state.response}");
              _currentOrders.clear();
              _currentOrders.addAll(temOrders);
              consignListController.add(contrConsignTypeRefresh);
            }
          }
        },
        child: BlocListener<ExchangeDetailBloc, AllPageState>(
          bloc: exchangeDetailBloc,
          listener: (ctx, state) {
            if (state is ExchangeMarketInfoState) {
              marketInfoEntity = state.marketInfoEntity;
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
                      delegationListView(buyChartList, sailChartList),
                      /*Row(
                    children: <Widget>[
                      Expanded(flex: 4, child: _depthChart()),
                    ],
                  ),*/
                      _exchangeOptions(),
                      _consignList()
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
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
            '+13.0%',
            style: TextStyle(
              color: isBuy ? HexColor("#53AE86") : HexColor("#CC5858"),
              fontSize: 13.0,
            ),
          ),
          decoration: BoxDecoration(
              color: isBuy ? HexColor("#EBF8F2") : HexColor("#F9EFEF"),
              borderRadius: BorderRadius.circular(4.0)),
        ),
        Spacer(),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.equalizer),
        )
      ],
    );
  }

  updateTotalView(double totalPrice) {
    totalPriceStr = totalPrice.toStringAsFixed(marketInfoEntity.turnoverPrecision);
    totalEditController.text = totalPriceStr;
    totalEditController.selection = TextSelection.fromPosition(TextPosition(offset: totalPriceStr.length));
  }

  double getValidNum() {
    if (exchangeModel.isActiveAccount()) {
      if (isBuy) {
        return double.parse(exchangeModel.activeAccount.assetList
            .getAsset(widget.selectedCoin.toUpperCase())
            .exchangeAvailable);
      } else {
        return double.parse(exchangeModel.activeAccount?.assetList
            ?.getAsset("HYN")
            ?.exchangeAvailable);
      }
    } else {
      return 0;
    }
  }

  Widget _exchangeOptions() {
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
            priceEditController.selection = TextSelection.fromPosition(
                TextPosition(offset: currentPriceStr.length));
          } else if (optionKey == contrOptionsTypePriceAdd) {
            var preNum = math.pow(10, marketInfoEntity.pricePrecision);
            currentPrice += (1 / preNum);
            var totalPrice = currentPrice * currentNum;
            updateTotalView(totalPrice);

            currentPriceStr =
                currentPrice.toStringAsFixed(marketInfoEntity.pricePrecision);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(
                TextPosition(offset: currentPriceStr.length));
          } else if (optionKey == contrOptionsTypePriceDecrease) {
            var preNum = math.pow(10, marketInfoEntity.pricePrecision);
            currentPrice -= (1 / preNum);
            var totalPrice = currentPrice * currentNum;
            updateTotalView(totalPrice);

            currentPriceStr =
                currentPrice.toStringAsFixed(marketInfoEntity.pricePrecision);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(
                TextPosition(offset: '$currentPriceStr'.length));
          } else if (optionKey == contrOptionsTypeNum) {
            var totalPrice = currentPrice * currentNum;
            updateTotalView(totalPrice);

            currentNumStr = currentNum.toString();
          } else if (optionKey == contrOptionsTypeNumPercent) {
            if(exchangeModel.isActiveAccount()){
              currentNum = getValidNum() * double.parse(optionValue);
              var totalPrice = currentPrice * currentNum;
              updateTotalView(totalPrice);

              currentNumStr = currentNum.toStringAsFixed(marketInfoEntity.amountPrecision);
              numEditController.text = currentNumStr;
              numEditController.selection = TextSelection.fromPosition(
                  TextPosition(offset: currentNumStr.length));
            }
          } else if (optionKey == contrOptionsTypeNumPreError) {
            numEditController.text = currentNumStr;
            numEditController.selection = TextSelection.fromPosition(
                TextPosition(offset: currentNumStr.length));
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
                          optionsController.add({contrOptionsTypeBuy:""});
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
                          optionsController.add({contrOptionsTypeSell:""});
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
                                  currentPrice = double.parse(price);
                                  optionsController.add({contrOptionsTypePrice:""});
                                } else {
                                  optionsController.add({contrOptionsTypePricePreError:""});
                                }
                              } else {
                                if (price.length == 0) {
                                  currentPrice = 0;
                                } else {
                                  currentPrice = double.parse(price);
                                }
                                optionsController.add({contrOptionsTypePrice:""});
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
                            optionsController.add({contrOptionsTypePriceDecrease:""});
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
                              optionsController.add({contrOptionsTypePriceAdd:""});
                            },
                            child: Padding(
                                padding: EdgeInsets.only(top: 7, bottom: 7, left: 17, right: 17),
                                child: Text("+", style: TextStyle(color: DefaultColors.color999)))),
                      ],
                    )),
                /*Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        optionsController.add(contrOptionsTypePriceDecrease);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 12),
                        child: Text(
                          "-",
                          style: TextStyle(fontSize: 21, color: DefaultColors.color999),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: priceEditController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                        decoration: new InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          border: InputBorder.none,
                          hintStyle: TextStyles.textCaaaS14,
                          hintText: "价格",
                        ),
                        onChanged: (price) {
                          if (price.contains(".")) {
                            var priceAfter = price.split(".")[1];
                            if (priceAfter.length <= marketInfoEntity.pricePrecision) {
                              currentPrice = double.parse(price);
                              optionsController.add(contrOptionsTypePrice);
                            } else {
                              optionsController.add(contrOptionsTypePricePreError);
                            }
                          } else {
                            currentPrice = double.parse(price);
                            optionsController.add(contrOptionsTypePrice);
                          }
                        },
                      ),
                    ),
                    Text("USDT"),
                    InkWell(
                        onTap: () {
                          optionsController.add(contrOptionsTypePriceAdd);
                        },
                        child: Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
                            child: Text("+", style: TextStyle(color: DefaultColors.color999)))),
                  ],
                ),*/
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
                                currentNum = double.parse(number);
                                optionsController.add({contrOptionsTypeNum:""});
                              } else {
                                optionsController.add({contrOptionsTypeNumPreError:""});
                              }
                            } else {
                              if (number.length == 0) {
                                currentNum = 0;
                              } else {
                                currentNum = double.parse(number);
                              }
                              optionsController.add({contrOptionsTypeNum:""});
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: FlatButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              optionsController.add({contrOptionsTypeNumPercent:"0.25"});
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
                              optionsController.add({contrOptionsTypeNumPercent:"0.5"});
                            },
                            child: Text("50%", style: TextStyle(fontSize: 10, color: DefaultColors.color999))),
                      ),
                      SizedBox(
                        width: 36,
                        child: FlatButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              optionsController.add({contrOptionsTypeNumPercent:"1"});
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
                          onChanged: (number) {
                            if (number.contains(".")) {
                              var priceAfter = number.split(".")[1];
                              if (priceAfter.length <= marketInfoEntity.amountPrecision) {
                                currentNum = double.parse(number);
                                optionsController.add({contrOptionsTypeNum:""});
                              } else {
                                optionsController.add({contrOptionsTypeNumPreError:""});
                              }
                            } else {
                              currentNum = double.parse(number);
                              optionsController.add({contrOptionsTypeNum:""});
                            }
                          },
                        ),
                      ),
//                      Expanded(child: Text("$totalPriceStr")),
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
                        optionsController.add({contrOptionsTypeRefresh:""});

                        await buyAction();
                        isLoading = false;
                        optionsController.add({contrOptionsTypeRefresh:""});
                      }),
                )
              ],
            ),
          );
        });
  }

//  Widget _exchangeOptionsOld() {
//    return StreamBuilder<int>(
//        stream: optionsController.stream,
//        builder: (context, optionType) {
//          if (optionType.data == contrOptionsTypeBuy) {
//            isBuy = true;
//          } else if (optionType.data == contrOptionsTypeSell) {
//            isBuy = false;
//          } else if (optionType.data == contrOptionsTypeLimit) {
//            isLimit = true;
//          } else if (optionType.data == contrOptionsTypeMarket) {
//            isLimit = false;
//          } else if (optionType.data == contrOptionsTypePrice) {
//            totalPrice = currentPrice * currentNum;
//          } else if (optionType.data == contrOptionsTypePriceAdd) {
//            currentPrice += 0.1;
//            totalPrice = currentPrice * currentNum;
//            totalPriceStr = totalPrice.toStringAsFixed(4);
//
//            currentPriceStr = currentPrice.toStringAsFixed(4);
//            priceEditController.text = currentPriceStr;
//            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: currentPriceStr.length));
//          } else if (optionType.data == contrOptionsTypePriceDecrease) {
//            currentPrice -= 0.1;
//            totalPrice = currentPrice * currentNum;
//            totalPriceStr = totalPrice.toStringAsFixed(4);
//
//            currentPriceStr = currentPrice.toStringAsFixed(4);
//            priceEditController.text = currentPriceStr;
//            priceEditController.selection = TextSelection.fromPosition(TextPosition(offset: '$currentPriceStr'.length));
//          } else if (optionType.data == contrOptionsTypeNum) {
//            totalPrice = currentPrice * currentNum;
//            totalPriceStr = totalPrice.toStringAsFixed(4);
//
//            currentPriceStr = currentPrice.toStringAsFixed(4);
//          }
//          return Container(
//            padding: const EdgeInsets.only(left: 14.0, right: 14),
//            width: double.infinity,
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Expanded(
//                      child: InkWell(
//                        onTap: () {
//                          optionsController.add(contrOptionsTypeBuy);
//                        },
//                        child: Container(
//                          height: 30,
//                          decoration: BoxDecoration(
//                            color: Colors.white,
//                            image: DecorationImage(
//                                image: AssetImage(isBuy
//                                    ? "res/drawable/ic_exchange_bg_left_buy_select.png"
//                                    : "res/drawable/ic_exchange_bg_left_buy.png"),
//                                fit: BoxFit.fitWidth),
//                          ),
//                          alignment: Alignment.center,
//                          child: Text('买入'),
//                        ),
//                      ),
//                    ),
//                    Expanded(
//                      child: InkWell(
//                        onTap: () {
//                          optionsController.add(contrOptionsTypeSell);
//                        },
//                        child: Container(
//                          height: 30,
//                          decoration: BoxDecoration(
//                            color: Colors.white,
//                            image: DecorationImage(
//                                image: AssetImage(isBuy
//                                    ? "res/drawable/ic_exchange_bg_right_sell.png"
//                                    : "res/drawable/ic_exchange_bg_right_sell_select.png"),
//                                fit: BoxFit.fitWidth),
//                          ),
//                          alignment: Alignment.center,
//                          child: Text('卖出'),
//                        ),
//                      ),
//                    )
//                  ],
//                ),
//                SizedBox(
//                  height: 10,
//                ),
//                Container(
//                    height: 28,
//                    padding: const EdgeInsets.only(left: 10, right: 10),
//                    decoration: BoxDecoration(
//                        border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
//                        borderRadius: BorderRadius.all(Radius.circular(3))),
//                    child: new DropdownButtonHideUnderline(
//                        child: new DropdownButton(
//                      icon: Image.asset(
//                        "res/drawable/ic_exchange_down_triangle.png",
//                        width: 10,
//                      ),
//                      items: [
//                        new DropdownMenuItem(
//                          child: new Text('限价委托'),
//                          value: contrOptionsTypeLimit,
//                        ),
//                        new DropdownMenuItem(
//                          child: new Text('市价委托'),
//                          value: contrOptionsTypeMarket,
//                        ),
//                      ],
//                      hint: new Text('请选择'),
//                      onChanged: (value) {
//                        optionsController.add(value);
//                      },
//                      isExpanded: true,
//                      value: isLimit ? contrOptionsTypeLimit : contrOptionsTypeMarket,
//                      style: new TextStyle(
//                        color: DefaultColors.color333,
//                        fontSize: 14,
//                      ),
//                    ))),
//                Container(
//                    height: 32,
//                    margin: EdgeInsets.only(top: 10, bottom: 2),
//                    padding: const EdgeInsets.only(left: 10),
//                    decoration: BoxDecoration(
//                        border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
//                        borderRadius: BorderRadius.all(Radius.circular(3))),
//                    child: Row(
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      children: <Widget>[
//                        Expanded(
//                          child: TextField(
//                            controller: priceEditController,
//                            keyboardType: TextInputType.number,
//                            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
//                            decoration: new InputDecoration(
//                              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
//                              border: InputBorder.none,
//                              hintStyle: TextStyles.textCaaaS14,
//                              hintText: "价格",
//                            ),
//                            onChanged: (price) {
//                              currentPrice = double.parse(price);
//                              optionsController.add(contrOptionsTypePrice);
//                            },
//                          ),
//                        ),
//                        Container(
//                          width: 1,
//                          color: DefaultColors.colord0d0d0,
//                        ),
//                        InkWell(
//                          onTap: () {
//                            optionsController.add(contrOptionsTypePriceDecrease);
//                          },
//                          child: Padding(
//                            padding: EdgeInsets.only(left: 12, right: 12),
//                            child: Text(
//                              "-",
//                              style: TextStyle(fontSize: 21, color: DefaultColors.color999),
//                            ),
//                          ),
//                        ),
//                        Container(
//                          width: 1,
//                          height: 20,
//                          color: DefaultColors.colord0d0d0,
//                        ),
//                        InkWell(
//                            onTap: () {
//                              optionsController.add(contrOptionsTypePriceAdd);
//                            },
//                            child: Padding(
//                                padding: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
//                                child: Text("+", style: TextStyle(color: DefaultColors.color999)))),
//                      ],
//                    )),
//                Text("≈324234 CNY"),
//                Container(
//                  height: 32,
//                  margin: EdgeInsets.only(top: 12, bottom: 2),
//                  padding: const EdgeInsets.only(left: 10, right: 10),
//                  decoration: BoxDecoration(
//                      border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
//                      borderRadius: BorderRadius.all(Radius.circular(3))),
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: TextField(
//                          controller: numEditController,
//                          keyboardType: TextInputType.number,
//                          inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
//                          decoration: new InputDecoration(
//                            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
//                            border: InputBorder.none,
//                            hintStyle: TextStyles.textCaaaS14,
//                            hintText: "数量",
//                          ),
//                          onChanged: (number) {
//                            currentNum = double.parse(number);
//                            optionsController.add(contrOptionsTypeNum);
//                          },
//                        ),
//                      ),
//                      Spacer(),
//                      Text("ETH")
//                    ],
//                  ),
//                ),
//                Text("可用 0.323423424 USDT"),
//                /*Container(
//                    margin: EdgeInsets.only(top: 21),
//                    height: 22,
//                    width: double.infinity,
//                    child: CustomSeekBar(
//                      progresseight: 5,
//                      value: 50,
//                      sectionCount: 4,
//                      sectionRadius: 5,
//                      indicatorRadius: 10,
//                      sectionColor: DefaultColors.color53ae86,
//                      indicatorImg: "res/drawable/ic_exchange_num_progress_buy.png",
//                    )),*/
//                Text("交易额 ${totalPriceStr}USDT"),
//                Container(
//                  height: 30,
//                  width: double.infinity,
//                  decoration: BoxDecoration(
//                    borderRadius: BorderRadius.all(Radius.circular(4)),
//                    color: isBuy ? DefaultColors.color53ae86 : DefaultColors.colorcc5858,
//                  ),
//                  child: FlatButton(
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
//                      ),
//                      padding: const EdgeInsets.all(0.0),
//                      child: Text(isLogin ? isBuy ? "买入HYN" : "卖出HYN" : "请登录",
//                          style: TextStyle(
//                            fontSize: 14,
//                            color: isLoading ? DefaultColors.color999 : Colors.white,
//                          )),
//                      onPressed: isLoading
//                          ? null
//                          : () async {
//                              setState(() {
//                                isLoading = true;
//                              });
//                              await buyAction();
//                              setState(() {
//                                isLoading = false;
//                              });
//                            }),
//                )
//              ],
//            ),
//          );
//        });
//  }

//  Widget _depthChart() {
//    return ListView.builder(
//        shrinkWrap: true,
//        physics: NeverScrollableScrollPhysics(),
//        scrollDirection: Axis.vertical,
//        itemBuilder: (context, index) {
//          ExcDetailEntity excDetailEntity = chartList[index];
//          if (excDetailEntity.viewType == 2 || excDetailEntity.viewType == 4) {
//            Color bgColor = excDetailEntity.viewType == 2 ? HexColor("#EBF8F2") : HexColor("#F9EFEF");
//            return Stack(
//              alignment: Alignment.center,
//              children: <Widget>[
//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      flex: excDetailEntity.leftPercent,
//                      child: Container(
//                        height: 23,
//                        color: HexColor("#ffffff"),
//                      ),
//                    ),
//                    Expanded(
//                      flex: excDetailEntity.rightPercent,
//                      child: Container(
//                        height: 23,
//                        color: bgColor,
//                      ),
//                    )
//                  ],
//                ),
//                Row(
//                  children: <Widget>[
//                    Text(
//                      "1111",
//                    ),
//                    Spacer(),
//                    Text(
//                      "1111",
//                    )
//                  ],
//                ),
//              ],
//            );
//          } else {
//            return Text("");
//          }
//        },
//        itemCount: chartList.length);
//  }

  Widget _consignList() {
    return StreamBuilder<int>(
      stream: consignListController.stream,
      builder: (context, optionType) {
        if (optionType.data == contrConsignTypeRefresh) {}
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _currentOrders.length + 1,
            itemBuilder: (ctx, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 13.0, bottom: 11, left: 13, right: 13),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "当前委托",
                            style: TextStyle(
                                fontSize: 16, color: DefaultColors.color333),
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
                                          builder: (context) =>
                                              ExchangeOrderManagementPage(
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
                );
              }

              return OrderItem(
                _currentOrders[index - 1],
                market: marketCoin,
              );
            });
      },
    );
  }

  Future changeDepthLevel(int newLevel) {
    BlocProvider.of(context).add(UnSubChannelEvent(channel: depthChannel));
    depthChannel = SocketConfig.channelExchangeDepth("symbo", newLevel);
    BlocProvider.of(context).add(SubChannelEvent(channel: depthChannel));
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
        exchangeDetailBloc.add(LimitExchangeEvent(
            marketCoin, exchangeType, currentPriceStr, currentNumStr));
      } else {
        exchangeDetailBloc
            .add(MarketExchangeEvent(marketCoin, exchangeType, currentNumStr));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
    }
  }
}
