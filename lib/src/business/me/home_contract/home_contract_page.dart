import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/me/home_contract/contract_bloc/bloc.dart';
import 'package:titan/src/business/me/home_contract/order_contract/order_contract_state.dart';
import 'package:titan/src/business/me/home_contract/contract_bloc/contract_state.dart';
import 'package:titan/src/business/me/home_contract/order_contract/bloc.dart';
import 'package:titan/src/business/me/purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';

import '../model/contract_info_v2.dart';
import '../my_hash_rate_page.dart';
import '../purchase_contract_page.dart';


class HomeContractPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeContractState();
  }
}

class _HomeContractState extends State<HomeContractPage> {
  UserService _userService = UserService();

  List<ContractInfoV2> contractList = [ContractInfoV2(0, "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0)];

  ContractInfoV2 _selectedContractInfo = ContractInfoV2(0, "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0);

  NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.#####");

  HomeContractBloc _contractBloc;

  OrderContractBloc _orderContractBloc;

  @override
  void initState() {
    super.initState();
    _contractBloc = HomeContractBloc(_userService);
    _orderContractBloc = OrderContractBloc(_userService, _contractBloc);
    _contractBloc.add(LoadContracts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          title: Text(
            "宅经济体验合约",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<HomeContractBloc, ContractState>(
            bloc: _contractBloc,
            builder: (BuildContext context, ContractState contractState) {
              if (contractState is LoadedState) {
                contractList = [contractState.contrctInfoList.first];
                _selectedContractInfo = contractList[0];
              } else if (contractState is ContractSwitchedState) {
                _selectedContractInfo = contractList[contractState.index];
              }
              return BlocBuilder<OrderContractBloc, OrderContractState>(
                bloc: _orderContractBloc,
                builder: (context, orderContractState) {
                  if (orderContractState is OrderSuccessState) {
                    print("1111");

                    _orderContractBloc.add(ResetToInit());
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PurchaseContractPage(
                                    contractInfo: _selectedContractInfo,
                                    payOrder: orderContractState.payOrder,
                                  )));
                      return;
                    });
                  } else if (orderContractState is OrderFreeSuccessState) {
                    print("222");

                    Fluttertoast.showToast(msg: S.of(context).receive_success_hint);
                    _orderContractBloc.add(ResetToInit());
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                      return;
                    });
                  } else if (orderContractState is OrderOverRangeState) {
                    Fluttertoast.showToast(msg: S.of(context).over_limit_numbers);
                  } else if (orderContractState is OrderFailState) {
                    Fluttertoast.showToast(msg: S.of(context).mortgage_fail_hint);
                  }

                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              child: CarouselSlider.builder(
                                itemCount: 1,
                                itemBuilder: (context, index){
                                  return Builder(
                                    builder: (BuildContext context) {
                                      var _contractInfoTemp = _selectedContractInfo;
                                      return Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                  child: Center(
                                                    child: Image.network(_contractInfoTemp.icon),
                                                    /*FadeInImage.assetNetwork(
                                                  image: _contractInfoTemp.icon,
                                                  placeholder: 'res/drawable/img_placeholder_circle.png',
//                                                height: constraint.biggest.height,
                                                  fit: BoxFit.cover,
                                                )*/
                                                  )),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        _contractInfoTemp.name,
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            '${DOUBLE_NUMBER_FORMAT.format(_contractInfoTemp.amount == 0 ? 10 : _contractInfoTemp.amount)}',
                                                            style: TextStyle(
                                                                color: Color(0xFFf6927f),
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          Text(
                                                            " USDT",
                                                            style: TextStyle(
                                                              color: Color(0xFFf6927f),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(S.of(context).n_days_product("${_contractInfoTemp.timeCycle}")),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            DOUBLE_NUMBER_FORMAT.format(_contractInfoTemp.totalIncome),
                                                            style: TextStyle(
                                                                color: Color(0xFFf6927f),
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          Text(
                                                            " USDT",
                                                            style: TextStyle(
                                                              color: Color(0xFFf6927f),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ));
                                    },
                                  );
                                },
                                onPageChanged: _onPageChanged,
                                height: 280.0,
                                enlargeCenterPage: true,
                                realPage: 1,
                                enableInfiniteScroll: false,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Container(
                              margin: EdgeInsets.only(left: 32, right: 32, bottom: 16, top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "宅经济体验合约介绍",
                                        style:
                                            TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
//                                      Spacer(),
//                                      Text(
//                                        "每人限抵${_selectedContractInfo.limit}份",
//                                        style: TextStyle(color: Colors.grey, fontSize: 14),
//                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        "宅经济体验合约为体验合约，10USDT一份，统一使用HYN进行抵押，体验上限100份，达到上限后不可重复参与。\nAI自动巡检范围：约30m² \n\nPOH算力旨在...",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: (_selectedContractInfo.remaining ?? 0) > 0
                                        ? (orderContractState is OrderingState ? null : _orderSubmit)
                                        : null,
                                    child: Container(
                                      constraints: BoxConstraints.expand(height: 48),
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              orderContractState is OrderingState
                                                  ? S.of(context).commiting
                                                  : (_selectedContractInfo.amount != 0 ? S.of(context).mortgage : S.of(context).free_receive),
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              S.of(context).available_mortgage_numbers('${_selectedContractInfo.remaining??0}'),
                                              style: TextStyle(color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              );
            }));
  }

  Future _onPageChanged(int index) {
    _contractBloc.add(SwtichContract(index));
  }

  Function _orderSubmit() {

    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHashRatePage()));


    if (_selectedContractInfo.amount > 0) {
      _orderContractBloc.add(OrderContract(_selectedContractInfo.id));
    } else {
      _orderContractBloc.add(OrderFreeContract(_selectedContractInfo.id));
    }
  }
}
