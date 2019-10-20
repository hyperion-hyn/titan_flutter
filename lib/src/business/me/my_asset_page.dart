import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/business/me/draw_balance_page.dart';
import 'package:titan/src/business/me/model/bill_info.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/withdrawal_info_log.dart';
import 'package:titan/src/business/me/recharge_purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/widget/smart_pull_refresh.dart';
import "enter_recharge_count.dart";

class MyAssetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAssetState();
  }
}

class _MyAssetState extends UserState<MyAssetPage> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: <Widget>[
          Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      var isSuccess =
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => DrawBalancePage()));
                      if (isSuccess != null && isSuccess) {
                        eventBus.fire(Refresh());
                        _tabController.animateTo(1);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "提币",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return EnterRechargeCount();
                          }).then((rechargeAmount) async {
                        if (rechargeAmount == null) {
                          return;
                        }
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RechargePurchasePage(rechargeAmount: rechargeAmount)))
                            .then((value) async {
                          if (value == null || value == false) {
                            return;
                          }
                          await UserService.syncUserInfo();
                          setState(() {});
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "充值",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 0, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            "账户余额(USDT)",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.balance)} ",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Text(
                            "收益余额",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.balance - LOGIN_USER_INFO.chargeBalance)} ",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Text(
                            "充值余额",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.chargeBalance)} ",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
//                padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
//                      color: Colors.black54,
                    width: 200,
                    child: TabBar(
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 5,
                      controller: _tabController,
                      labelColor: Color(0xFF252525),
                      unselectedLabelColor: Colors.grey,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: <Widget>[
                        Tab(
                          child: Text(
                            '账单流水',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '提币记录',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],

//                        indicatorColor: Color(0xFFcb9521),
                    ),
                  ),
                  Expanded(
                    child: RefreshConfiguration.copyAncestor(
                      enableLoadingWhenFailed: true,
                      context: context,
                      headerBuilder: () => WaterDropMaterialHeader(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      footerTriggerDistance: 30.0,
                      child: TabBarView(
                        controller: _tabController,
                        physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[
                          BillHistory(),
                          WithdrawalHistory(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BillHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BillHistoryState();
  }
}

class _BillHistoryState extends DataListState<BillHistory> {
  UserService _userService = UserService();

  StreamSubscription _eventBusSubscription;

//  List<BillInfo> billList = [];
//  int currentPage = 0;
//  LoadDataBloc loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
//    _getBillList(0);
    _listenEventBus();
  }

  @override
  void postFrameCallBackAfterInitState() {
    loadDataBloc.dispatch(LoadingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return LoadDataContainer(
      bloc: loadDataBloc,
      onLoadData: onWidgetLoadDataCallback,
      onRefresh: onWidgetRefreshCallback,
      onLoadingMore: onWidgetLoadingMoreCallback,
      child: ListView.separated(
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _buildBillDetailItem(dataList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                thickness: 0.5,
                color: Colors.black12,
              ),
            );
          },
          itemCount: dataList.length),
    );
  }

  Widget _buildBillDetailItem(BillInfo billInfo) {
    var amountColor = Colors.black;
    if (billInfo.amount > 0) {
      amountColor = HexColor("#6DBA1A");
    } else {
      amountColor = HexColor("#D0021B");
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  billInfo.title,
                  style: TextStyle(fontSize: 16, color: HexColor("#252525")),
                ),
              ),
              if (billInfo.subTitle != null)
                Text(
                  billInfo.subTitle,
                  style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                )
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  Const.DOUBLE_NUMBER_FORMAT.format(billInfo.amount),
                  style: TextStyle(fontSize: 16, color: amountColor, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(billInfo.crateAt * 1000)),
                style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Future<List> onLoadData(int page) {
    return _userService.getBillList(page);
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      print("event:$event");
      if (event is Refresh) {
//        _getBillList(0);
        loadDataBloc.dispatch(RefreshingEvent());
      }
    });
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
    loadDataBloc.dispose();
    super.dispose();
  }
}

class BillDetailVo {
  String title;
  String subTitle;
  String time;
  String amountStr;

  BillDetailVo({this.title, this.subTitle, this.time, this.amountStr});
}

//////////

class WithdrawalHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WithdrawalState();
  }
}

class _WithdrawalState extends DataListState<WithdrawalHistory> {
  UserService _userService = UserService();

  StreamSubscription _eventBusSubscription;

//  List<WithdrawalInfoLog> withdrawalInfoList = [];
//  LoadDataBloc loadDataBloc = LoadDataBloc();
//  PageResponse<WithdrawalInfoLog> _pageResponse = PageResponse(0, 0, []);
//  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _listenEventBus();
//    _getWithdrawalList(0);
  }

  @override
  void postFrameCallBackAfterInitState() {
    loadDataBloc.dispatch(LoadingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return LoadDataContainer(
      bloc: loadDataBloc,
      onLoadData: onWidgetLoadDataCallback,
      onRefresh: onWidgetRefreshCallback,
      onLoadingMore: onWidgetLoadingMoreCallback,
      child: ListView.separated(
          physics: ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _buildWithdrawalItem(dataList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                thickness: 0.5,
                color: Colors.black12,
              ),
            );
          },
          itemCount: dataList.length),
    );
  }

  Widget _buildWithdrawalItem(WithdrawalInfoLog withdrawalInfo) {
    Color stateColor = Color(0xFF6DBA1A);

    Color successColor = Color(0xFF6DBA1A);
    Color failColor = Color(0xFFD0021B);

    Color warnColor = Color(0xFFF7C43E);

    Color grayColor = Colors.grey[500];

//    waitForAudit: 待审核
//    unapprove：审核不通过
//    waitForTXConfirm: 已经转账，等待区块交易确认
//    haveTransfer：转账完成
//    transferFail：转账失败
//    approved：审核通过

    if (withdrawalInfo.state == "waitForAudit") {
      stateColor = warnColor;
    } else if (withdrawalInfo.state == "unapprove") {
      stateColor = failColor;
    } else if (withdrawalInfo.state == "waitForTXConfirm") {
      stateColor = successColor;
    } else if (withdrawalInfo.state == "haveTransfer") {
      stateColor = grayColor;
    } else if (withdrawalInfo.state == "transferFail") {
      stateColor = failColor;
    } else if (withdrawalInfo.state == "approved") {
      stateColor = successColor;
    } else if (withdrawalInfo.state == "rollback:") {
      stateColor = failColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "提币：${Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo.amount)}",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Text(
                "手续费：${Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo.fee)}",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  withdrawalInfo.stateTitle,
                  style: TextStyle(fontSize: 14, color: stateColor),
                ),
              ),
              Text(
                Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(withdrawalInfo.createAt * 1000)),
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Future<List> onLoadData(int page) async {
    PageResponse<WithdrawalInfoLog> _pageResponse = await _userService.getWithdrawalLogList(page);
    var dataList = _pageResponse.data;
    return dataList;
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      print("event:$event");
      if (event is Refresh) {
//        _getWithdrawalList(0);
        loadDataBloc.dispatch(RefreshingEvent());
      }
    });
  }

  @override
  void dispose() {
    loadDataBloc.dispose();
    _eventBusSubscription?.cancel();
    super.dispose();
  }

}

class Refresh {}
