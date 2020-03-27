import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/business/me/draw_balance_page.dart';
import 'package:titan/src/business/me/model/bill_info.dart';
import 'package:titan/src/business/me/model/daily_bills_type.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/withdrawal_info_log.dart';
import 'package:titan/src/business/me/recharge_purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'me_dailybills_detail_page.dart';

import "enter_recharge_count.dart";

class MyContractRecordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyContractRecordState();
  }
}

class _MyContractRecordState extends UserState<MyContractRecordPage> with TickerProviderStateMixin {
  TabController _tabController;
  List<DailyBillsModel> _dailyBillsModels;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    List<DailyBillsModel> list = [
      DailyBillsModel(S.of(context).all_bills, DailyBillsType.all),
      DailyBillsModel(S.of(context).contract_bills, DailyBillsType.contract),
      DailyBillsModel(S.of(context).node_bills, DailyBillsType.node),
      DailyBillsModel(S.of(context).reward_bills, DailyBillsType.reward),
      DailyBillsModel(S.of(context).recharge_withdrawal_bills, DailyBillsType.inAndOut),
    ];
    _dailyBillsModels = list;
    _tabController = TabController(length: _dailyBillsModels.length, vsync: this);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(S.of(context).contract_record,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[

          Expanded(
            child: Container(
//                padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          width: 200,
                          child: TabBar(
                            isScrollable: true,
                            indicatorColor: Theme.of(context).primaryColor,
                            indicatorWeight: 5,
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            //labelColor: Color(0xFF252525),
                            unselectedLabelColor: Colors.grey,
                            indicatorSize: TabBarIndicatorSize.label,
                            tabs: _dailyBillsModels.map((DailyBillsModel model) =>
                                Tab(
                                  child: Text(
                                    model.name,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                            ).toList(),
                          ),
                        ),
                      ),
                    ],
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
                        //physics: NeverScrollableScrollPhysics(),
                        children: _dailyBillsModels.map((DailyBillsModel value) =>
                            value.type==DailyBillsType.none?WithdrawalHistory():BillHistory(type: value.type)
                        ).toList(),
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
  final DailyBillsType type;
  BillHistory({this.type});

  @override
  State<StatefulWidget> createState() {
    return _BillHistoryState();
  }
}

class _BillHistoryState extends DataListState<BillHistory> {
  UserService _userService = UserService();
  StreamSubscription _eventBusSubscription;

  @override
  void initState() {
    super.initState();
    _listenEventBus();
  }

  @override
  void postFrameCallBackAfterInitState() {
    loadDataBloc.add(LoadingEvent());
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
            return _buildItem(dataList[index]);
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

  Widget _buildItem(BillInfo billInfo) {
    if (billInfo.hasDetail) {
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MeDailyBillsDetail(billInfo)));
        },
        child: _buildItemDetail(billInfo),
      );
    } else {
      return _buildItemDetail(billInfo);
    }
  }

  Widget _buildItemDetail(BillInfo billInfo) {
    var amountColor = Colors.black;
    if (billInfo.amount > 0) {
      amountColor = HexColor("#6DBA1A");
    } else {
      amountColor = HexColor("#D0021B");
    }

    String subTitle = billInfo.subTitle;
    //subTitle = '抵押ID 1,10,100,1000,10000,100000,1000000,10000000';
    if (subTitle.length > 25) {
      subTitle = subTitle.substring(0, 25) + '...';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
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
                  SizedBox(
                    child: Container(
                      child: Text(
                        subTitle,
                        style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    width: 180,
                  )
              ],
            ),
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
          ),
          Container(
            width: 16,
            height: 16,
            child: Icon(
              !billInfo.hasDetail ? null : Icons.chevron_right,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<List> onLoadData(int page) {
    return _userService.getBillList(page, type: widget.type);
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      if (event is Refresh) {
        loadDataBloc.add(RefreshingEvent());
      }
    });
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
    loadDataBloc.close();
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
    loadDataBloc.add(LoadingEvent());
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    S.of(context).withdrawal_with_quantity(Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo.amount)),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  S.of(context).poundage_with_quantity(Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo.fee)),
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                )
              ],
            ),
          ),
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
      if (event is Refresh) {
//        _getWithdrawalList(0);
        loadDataBloc.add(RefreshingEvent());
      }
    });
  }

  @override
  void dispose() {
    loadDataBloc.close();
    _eventBusSubscription?.cancel();
    super.dispose();
  }
}

class Refresh {}
