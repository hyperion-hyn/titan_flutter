import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/draw_balance_page.dart';
import 'package:titan/src/business/me/model/bill_info.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/withdrawal_info_log.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/widget/smart_pull_refresh.dart';

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
              child: GestureDetector(
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 0, bottom: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      "账户余额",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.balance)} USDT",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
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
                        controller: _tabController,
                        labelColor: Color(0xFF252525),
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
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

class _BillHistoryState extends State<BillHistory> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<BillInfo> billList = [];
  UserService _userService = UserService();

  StreamSubscription _eventBusSubscription;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _getBillList(0);
    _listenEventBus();
  }

  @override
  Widget build(BuildContext context) {
    return SmartPullRefresh(
        child: ListView.separated(
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return _buildBillDetailItem(billList[index]);
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
            itemCount: billList.length),
        onRefresh: () {
          _getBillList(0);
        },
        onLoading: () {
          _getBillList(currentPage + 1);
        });
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

  Future _getBillList(int page) async {
    var listData = await _userService.getBillList(page);
    if (listData.length == 0) {
      return;
    }
    if (page == 0) {
      billList.clear();
      billList.addAll(listData);
    } else {
      billList.addAll(listData);
    }
    currentPage = page;
    if (mounted) {
      setState(() {});
    }
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      print("event:$event");
      if (event is Refresh) {
        _getBillList(0);
      }
    });
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
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

class _WithdrawalState extends State<WithdrawalHistory> {
  PageResponse<WithdrawalInfoLog> _pageResponse = PageResponse(0, 0, []);
  List<WithdrawalInfoLog> withdrawalInfoList = [];
  UserService _userService = UserService();

  StreamSubscription _eventBusSubscription;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _getWithdrawalList(0);
    _listenEventBus();
  }

  @override
  Widget build(BuildContext context) {
    return SmartPullRefresh(
        child: ListView.separated(
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return _buildWithdrawalItem(withdrawalInfoList[index]);
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
            itemCount: withdrawalInfoList.length),
        onRefresh: () {
          _getWithdrawalList(0);
        },
        onLoading: () {
          _getWithdrawalList(currentPage + 1);
        });
  }

  Widget _buildWithdrawalItem(WithdrawalInfoLog withdrawalInfo) {
    Color stateColor = HexColor("#6DBA1A");

    Color successColor = HexColor("#6DBA1A");
    Color failColor = HexColor("#D0021B");

//    waitForAudit: 待审核
//    unapprove：审核不通过
//    waitForTXConfirm: 已经转账，等待区块交易确认
//    haveTransfer：转账完成
//    transferFail：转账失败
//    approved：审核通过

    if (withdrawalInfo.state == "waitForAudit") {
      stateColor = successColor;
    } else if (withdrawalInfo.state == "unapprove") {
      stateColor = failColor;
    } else if (withdrawalInfo.state == "waitForTXConfirm") {
      stateColor = successColor;
    } else if (withdrawalInfo.state == "haveTransfer") {
      stateColor = HexColor("#FF259B24");
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
                  style: TextStyle(fontSize: 16, color: stateColor),
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

  Future _getWithdrawalList(int page) async {
    _pageResponse = await _userService.getWithdrawalLogList(page);
    var dataList = _pageResponse.data;
    if (dataList.length == 0) {
      return;
    }
    if (page == 0) {
      withdrawalInfoList.clear();
      withdrawalInfoList.addAll(dataList);
    } else {
      withdrawalInfoList.addAll(dataList);
    }
    currentPage = page;
    if (mounted) {
      setState(() {});
    }
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      print("event:$event");
      if (event is Refresh) {
        _getWithdrawalList(0);
      }
    });
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
    super.dispose();
  }
}

class Refresh {}
