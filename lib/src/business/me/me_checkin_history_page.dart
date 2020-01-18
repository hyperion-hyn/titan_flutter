import 'dart:async';
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/model/checkin_history.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/business/me/model/page_response.dart';

class MeCheckInHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeCheckInHistory();
  }
}

class _MeCheckInHistory extends DataListState<MeCheckInHistory> {

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
          S.of(context).task_record,
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
            return _buildItem(dataList[index]);
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
        ),
      ),
    );
  }

  Widget _buildItem(CheckinHistory model) {

    String _detail = "";
    int _scanTimes = model.detail?.scanTimes??0;
    int _addPoiTimes = model.detail?.addPoiTimes??0;
    int _verifyPoiTimes= model.detail?.verifyPoiTimes??0;
    if ((model.detail != null) &&
        (_scanTimes > 0 || _addPoiTimes > 0 || _verifyPoiTimes > 0)
    ) {
      _detail = S.of(context).task_finished_func(_scanTimes.toString(), _addPoiTimes.toString(), _verifyPoiTimes.toString());
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      margin: EdgeInsets.only(bottom: 1),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 16, bottom: 10, left: 15, right: 10),
                child: Image.asset('res/drawable/checkin_history_progress.png',
                  height: 90,
                  width: 10,
                  fit: BoxFit.cover,),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.day,
                  style: TextStyle(color: HexColor('#777777'), fontSize: 12),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  model.total < 3 ? S.of(context).task_un_finished:S.of(context).task_finished,
//                  model.total < 3 ? S.of(context).task_finish_func('${model.total}'):S.of(context).task_finish_day_hint,
                  style: TextStyle(color: model.total < 3 ? HexColor('#333333'):HexColor('##6DBA1A'), fontSize: 14),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  _detail,
                  style: TextStyle(color: HexColor('#777777'), fontSize: 12),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }


  @override
  Future<List> onLoadData(int page) async{
    PageResponse<CheckinHistory> _pageResponse = await _userService.getHistoryListV2(page);
    var dataList = _pageResponse.data;
    return dataList;
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

class Refresh {}