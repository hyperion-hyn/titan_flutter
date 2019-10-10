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
        title: Text("我的账户"),
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
                  child: Text("提币"),
                ),
              ))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 32, bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      "余额",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.balance)} U",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
//                      color: Colors.black54,
                      width: 200,
                      child: TabBar(
                        tabs: <Widget>[
                          Tab(
                            child: Text('账单流水'),
                          ),
                          Tab(
                            child: Text('提币记录'),
                          ),
                        ],
                        controller: _tabController,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
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

  @override
  void initState() {
    super.initState();
    _getBillList(0);
    _listenEventBus();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      footer: ClassicFooter(
        loadStyle: LoadStyle.ShowAlways,
        completeDuration: Duration(milliseconds: 500),
      ),
      header: WaterDropHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(Duration(milliseconds: 1000));

        _getBillList(0);
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(Duration(milliseconds: 1000));
//        for (int i = 0; i < 10; i++) {
//          data.add("Item $i");
//        }
        if (mounted) setState(() {});
        _refreshController.loadComplete();
//        _refreshController.loadFailed();
      },
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
    );
  }

  Widget _buildBillDetailItem(BillInfo billInfo) {
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
                  style: TextStyle(fontSize: 16),
                ),
              ),
              if (billInfo.subTitle != null)
                Text(
                  billInfo.subTitle,
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
                  Const.DOUBLE_NUMBER_FORMAT.format(billInfo.amount),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Text(
                Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(billInfo.crateAt * 1000)),
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )
            ],
          )
        ],
      ),
    );
  }

  Future _getBillList(int page) async {
    billList = await _userService.getBillList(page);
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
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  PageResponse _pageResponse = PageResponse(0, 0, []);
  List<WithdrawalInfoLog> withdrawalInfoList = [];
  UserService _userService = UserService();

  StreamSubscription _eventBusSubscription;

  @override
  void initState() {
    super.initState();
    _getWithdrawalList(0);
    _listenEventBus();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      footer: ClassicFooter(
        loadStyle: LoadStyle.ShowAlways,
        completeDuration: Duration(milliseconds: 500),
      ),
      header: WaterDropHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await Future.delayed(Duration(milliseconds: 1000));

        _getWithdrawalList(0);
        _refreshController.refreshCompleted();

        /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
      },
      onLoading: () async {
        //monitor fetch data from network
        await Future.delayed(Duration(milliseconds: 1000));
//        for (int i = 0; i < 10; i++) {
//          data.add("Item $i");
//        }
        if (mounted) setState(() {});
        _refreshController.loadComplete();
//        _refreshController.loadFailed();
      },
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
    );
  }

  Widget _buildWithdrawalItem(WithdrawalInfoLog withdrawalInfo) {
    Color stateColor = HexColor("#FFFF9800");

//    waitForAudit: 待审核
//    unapprove：审核不通过
//    waitForTXConfirm: 已经转账，等待区块交易确认
//    haveTransfer：转账完成
//    transferFail：转账失败
//    approved：审核通过

    if (withdrawalInfo.state == "waitForAudit") {
      stateColor = HexColor("#FFFF9800");
    } else if (withdrawalInfo.state == "unapprove") {
      stateColor = Colors.red;
    } else if (withdrawalInfo.state == "waitForTXConfirm") {
      stateColor = HexColor("#FFFF9800");
    } else if (withdrawalInfo.state == "haveTransfer") {
      stateColor = HexColor("#FF259B24");
    } else if (withdrawalInfo.state == "transferFail") {
      stateColor = Colors.red;
    } else if (withdrawalInfo.state == "approved") {
      stateColor = HexColor("#FFFF9800");
    } else if (withdrawalInfo.state == "rollback:") {
      stateColor = Colors.red;
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
    withdrawalInfoList = _pageResponse.data;
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
