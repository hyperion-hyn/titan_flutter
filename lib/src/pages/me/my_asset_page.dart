import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/me/components/account/account_component.dart';
import 'package:titan/src/pages/me/draw_balance_page.dart';
import 'package:titan/src/pages/me/model/daily_bills_type.dart';
import 'package:titan/src/pages/me/model/page_response.dart';
import 'package:titan/src/pages/me/model/withdrawal_info_log.dart';
import 'package:titan/src/pages/me/recharge_purchase_page.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/routes/routes.dart';

class MyAssetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAssetState();
  }
}

class _MyAssetState extends BaseState<MyAssetPage> with TickerProviderStateMixin {
  TabController _tabController;
  List<DailyBillsModel> _dailyBillsModels;

  @override
  void onCreated() {
    UserService.syncUserInfo(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _dailyBillsModels = [
      DailyBillsModel(S.of(context).withdrawal_records, DailyBillsType.record),
    ];
    _tabController = TabController(length: _dailyBillsModels.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var userInfo = AccountInheritedModel.of(context, aspect: AccountAspect.userInfo).userInfo;
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
                      var isSuccess = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DrawBalancePage(),
                              settings: RouteSettings(name: "/draw_balance_page")));
                      if (isSuccess != null && isSuccess) {
                        Application.eventBus.fire(Refresh());
//                        _tabController.animateTo(1);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        S.of(context).withdrawal,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Application.router.navigateTo(context, Routes.recharge_purchase).then((isSuccess) async {
                        if (isSuccess == true) {
                          await UserService.syncUserInfo(context);
                          Application.eventBus.fire(Refresh());
                        }
                      });
//                      Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => RechargePurchasePage(),
//                                  settings: RouteSettings(name: "/recharge_purchase_page")))
//                          .then((isSuccess) async {
//                        if (isSuccess != null && isSuccess) {
//                          await UserService.syncUserInfo(context);
////                          setState(() {});
////                          _tabController.index = 0;
//                          Application.eventBus.fire(Refresh());
//                        }
//                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        S.of(context).recharge,
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
                            S.of(context).balance_with_unit,
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(userInfo.balance)} ",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          S.of(context).earnings_balance,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(userInfo.balance - userInfo.totalChargeBalance)} ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          S.of(context).recharge_balance,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
//                        Padding(
//                          padding: const EdgeInsets.only(left: 4.0),
//                          child: Text(
//                            '${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.totalChargeBalance)}',
//                            style: TextStyle(
//                              color: Colors.white,
//                              fontSize: 14,
//                            ),
//                          ),
//                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    S.of(context).hyn_eq_u,
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      '${Const.DOUBLE_NUMBER_FORMAT.format(userInfo.chargeHynBalance)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    S.of(context).usdt_direct,
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      '${Const.DOUBLE_NUMBER_FORMAT.format(userInfo.chargeUsdtBalance)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                            labelColor: Color(0xFF252525),
                            unselectedLabelColor: Colors.grey,
                            indicatorSize: TabBarIndicatorSize.label,
                            tabs: _dailyBillsModels
                                .map((DailyBillsModel model) => Tab(
                                      child: Text(
                                        model.name,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ))
                                .toList(),
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
                        children: _dailyBillsModels
                            .map((DailyBillsModel value) =>
                                value.type == DailyBillsType.record ? WithdrawalHistory() : Container())
                            .toList(),
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
    if(page == getStartPage()) {
      UserService.syncUserInfo(context);
    }
    PageResponse<WithdrawalInfoLog> _pageResponse = await _userService.getWithdrawalLogList(page);
    var dataList = _pageResponse.data;
    return dataList;
  }

  void _listenEventBus() {
    _eventBusSubscription = Application.eventBus.on().listen((event) async {
      if (event is Refresh) {
//        _getWithdrawalList(0);
        loadDataBloc.add(RefreshingEvent());
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
