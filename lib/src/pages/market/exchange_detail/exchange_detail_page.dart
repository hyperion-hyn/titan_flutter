import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/order/entity/order_entity.dart';
import 'package:titan/src/pages/market/entity/exc_detail_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/custom_seekbar/custom_seekbar.dart';

import 'bloc/exchange_detail_bloc.dart';

class ExchangeDetailPage extends StatefulWidget {
  final String symbol;
  final int type;

  ExchangeDetailPage({@required this.symbol, @required this.type});

  @override
  State<StatefulWidget> createState() {
    return ExchangeDetailPageState();
  }
}

class ExchangeDetailPageState extends State<ExchangeDetailPage> {
  ExchangeBloc exchangeBloc = ExchangeBloc();

  List<ExcDetailEntity> chartList = [];
  bool isLoading = false;
  bool isLogin = true;
  bool isBuy = true;
  bool isLimit = true;
  double currentPrice = 0;
  double totalPrice = 0;
  double currentNum = 0;
  String currentPriceStr = "";
  String totalPriceStr = "";
  String currentNumStr = "";

  TextEditingController priceEditController = new TextEditingController();
  TextEditingController numEditController = new TextEditingController();

  final int contrOptionsTypeBuy = 0;
  final int contrOptionsTypeSell = 1;
  final int contrOptionsTypeLimit = 2;
  final int contrOptionsTypeMarket = 3;
  final int contrOptionsTypePrice = 4;
  final int contrOptionsTypePriceAdd = 5;
  final int contrOptionsTypePriceDecrease = 6;
  final int contrOptionsTypeNum = 7;
  StreamController<int> optionsController = StreamController.broadcast();

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

    super.initState();
  }

  @override
  void dispose() {
    optionsController.close();
    exchangeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ExchangeBloc, AllPageState>(
        bloc: exchangeBloc,
        listener: (ctx, state) {},
        child: BlocBuilder<ExchangeBloc, AllPageState>(
          bloc: exchangeBloc,
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
    );
  }

  Widget exchangePageView() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _appBar(),
          Row(
            children: <Widget>[
              Expanded(flex: 6, child: _exchangeOptions()),
              Expanded(flex: 4, child: _depthChart()),
            ],
          ),
          _consignList()
        ],
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
            'HYN/${widget.symbol}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Container(
          padding: EdgeInsets.all(2.0),
          child: Text(
            '+13.0%',
            style: TextStyle(
              color: widget.type == ExchangeType.BUY ? Colors.red[400] : Colors.green[400],
              fontSize: 13.0,
            ),
          ),
          decoration: BoxDecoration(
              color: widget.type == ExchangeType.BUY ? Colors.red[50] : Colors.green[200],
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

  Widget _exchangeOptions() {
    return StreamBuilder<int>(
        stream: optionsController.stream,
        builder: (context, optionType) {
          if (optionType.data == contrOptionsTypeBuy) {
            isBuy = true;
          } else if (optionType.data == contrOptionsTypeSell) {
            isBuy = false;
          } else if (optionType.data == contrOptionsTypeLimit) {
            isLimit = true;
          } else if (optionType.data == contrOptionsTypeMarket) {
            isLimit = false;
          } else if (optionType.data == contrOptionsTypePrice) {
            totalPrice = currentPrice * currentNum;
          } else if (optionType.data == contrOptionsTypePriceAdd) {
            currentPrice += 0.1;
            totalPrice = currentPrice * currentNum;
            totalPriceStr = totalPrice.toStringAsFixed(4);

            currentPriceStr = currentPrice.toStringAsFixed(4);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(
                offset: currentPriceStr.length));
          } else if (optionType.data == contrOptionsTypePriceDecrease) {
            currentPrice -= 0.1;
            totalPrice = currentPrice * currentNum;
            totalPriceStr = totalPrice.toStringAsFixed(4);

            currentPriceStr = currentPrice.toStringAsFixed(4);
            priceEditController.text = currentPriceStr;
            priceEditController.selection = TextSelection.fromPosition(TextPosition(
                offset: '$currentPriceStr'.length));
          } else if (optionType.data == contrOptionsTypeNum) {
            totalPrice = currentPrice * currentNum;
            totalPriceStr = totalPrice.toStringAsFixed(4);

            currentPriceStr = currentPrice.toStringAsFixed(4);
          }
          return Container(
            padding: const EdgeInsets.only(left: 14.0, right: 14),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          optionsController.add(contrOptionsTypeBuy);
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
                      child: InkWell(
                        onTap: () {
                          optionsController.add(contrOptionsTypeSell);
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
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
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
                    ))),
                Container(
                    height: 32,
                    margin: EdgeInsets.only(top: 10, bottom: 2),
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
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
                            onChanged: (price){
                              currentPrice = double.parse(price);
                              optionsController.add(contrOptionsTypePrice);
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          color: DefaultColors.colord0d0d0,
                        ),
                        InkWell(
                          onTap: (){
                            optionsController.add(contrOptionsTypePriceDecrease);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 12,right: 12),
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
                            onTap: (){
                              optionsController.add(contrOptionsTypePriceAdd);
                            },
                            child: Padding(
                                padding: EdgeInsets.only(top:5,bottom: 5,left: 12,right: 12),
                                child: Text("+", style: TextStyle(color: DefaultColors.color999)))),
                      ],
                    )),
                Text("≈324234 CNY"),
                Container(
                  height: 32,
                  margin: EdgeInsets.only(top: 12, bottom: 2),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: DefaultColors.colord0d0d0),
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: numEditController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                            border: InputBorder.none,
                            hintStyle: TextStyles.textCaaaS14,
                            hintText: "数量",
                          ),
                          onChanged: (number){
                            currentNum = double.parse(number);
                            optionsController.add(contrOptionsTypeNum);
                          },
                        ),
                      ),
                      Spacer(),
                      Text("ETH")
                    ],
                  ),
                ),
                Text("可用 0.323423424 USDT"),
                /*Container(
                    margin: EdgeInsets.only(top: 21),
                    height: 22,
                    width: double.infinity,
                    child: CustomSeekBar(
                      progresseight: 5,
                      value: 50,
                      sectionCount: 4,
                      sectionRadius: 5,
                      indicatorRadius: 10,
                      sectionColor: DefaultColors.color53ae86,
                      indicatorImg: "res/drawable/ic_exchange_num_progress_buy.png",
                    )),*/
                Text("交易额 ${totalPriceStr}USDT"),
                Container(
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: DefaultColors.color53ae86,
                  ),
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
                      ),
                      padding: const EdgeInsets.all(0.0),
                      child: Text(isLogin ? "买入ETH" : "请登录",
                          style: TextStyle(
                            fontSize: 14,
                            color: isLoading ? DefaultColors.color999 : Colors.white,
                          )),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });
                              await buyAction();
                              setState(() {
                                isLoading = false;
                              });
                            }),
                )
              ],
            ),
          );
        });
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
                        color: bgColor,
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

  Widget _consignList() {
    return Text(
      "aaabbb",
      key: GlobalKey(),
    );
  }

  buyAction() {}
}
