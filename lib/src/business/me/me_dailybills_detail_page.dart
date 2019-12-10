import 'dart:async';
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/model/bill_info.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/global.dart';

class MeDailyBillsDetail extends StatefulWidget {
  final BillInfo _info;

  MeDailyBillsDetail(this._info);

  @override
  State<StatefulWidget> createState() {
    return _MeDailyBillsDetail();
  }
}

class _MeDailyBillsDetail extends DataListState<MeDailyBillsDetail> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).revenue_details,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: LoadDataContainer(
          bloc: loadDataBloc,
          onLoadData: onWidgetLoadDataCallback,
          onRefresh: onWidgetRefreshCallback,
          onLoadingMore: onWidgetLoadingMoreCallback,
          child: ListView.separated(
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return _buildItem(dataList[index], index);
            },
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: 0.5,
//                height: 0.5,
                  color: HexColor('#E9E9E9'),
                ),
              );
            },
            itemCount: dataList.length,
          )),
    );
  }

  Widget _buildItem(BillInfo billInfo, int index) {
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
          ),
        ],
      ),
    );
  }

  @override
  Future<List> onLoadData(int page) async {
    var dataList = await _userService.getDailyBillDetail(widget._info.id, page);
    //dataList.insert(0, widget._info);
    return dataList;
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      print("event:$event");
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

class Refresh {}
