import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/pages/contribution/contribution_tasks_page.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'me_checkin_history_detail_page.dart';

class MeCheckInHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeCheckInHistoryState();
  }
}

class _MeCheckInHistoryState extends DataListState<MeCheckInHistory> {
  dynamic _userService = Object();

  @override
  void postFrameCallBackAfterInitState() {
    loadDataBloc.add(LoadingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: '贡献记录',
        backgroundColor: Colors.white,
        actions: <Widget>[
          FlatButton(
            onPressed: _pushDetailView(null),
            child: Text(
              '详情',
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: HexColor('#F4F4F4'),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onLoadData: onWidgetLoadDataCallback,
          onRefresh: onWidgetRefreshCallback,
          onLoadingMore: onWidgetLoadingMoreCallback,
          child: ListView.separated(
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return _buildItem(index);
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                height: 10,
              );
            },
            itemCount: dataList.length,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    String title = "";
    String detail = "";
    var model = dataList[index] as CheckInModel;

    var scanCount = 0;
    var addPoiCount = 0;
    var confirmPoiCount = 0;
    CheckInModelDetail scanModel;
    CheckInModelDetail postPoiModel;
    CheckInModelDetail confirmPOIModel;

    if (model.detail.isNotEmpty) {
      for (var item in model.detail) {
        if (item.action == ContributionTasksPage.scanSignal) {
          scanModel = item;
        } else if (item.action == ContributionTasksPage.postPOI) {
          postPoiModel = item;
        } else if (item.action == ContributionTasksPage.confirmPOI) {
          confirmPOIModel = item;
        }
      }
      if (scanModel != null && scanModel.state != null) {
        scanCount = scanModel.state.total;
      }

      if (postPoiModel != null && postPoiModel.state != null) {
        addPoiCount = postPoiModel.state.total;
      }

      if (confirmPOIModel != null && confirmPOIModel.state != null) {
        confirmPoiCount = confirmPOIModel.state.total;

        for (var detail in confirmPOIModel.state.pois) {
          print("[me] original----answer:${detail.answer}, \nImgs:${detail.originalImgs}, \nimage:${detail.image}\n");
        }
      }
    }

    bool isFinish = model.completed;
    // todo: test_jison_0708
    /*if (confirmPOIModel?.state?.pois?.isNotEmpty??false) {
      isFinish = false;
    }*/
    // count
    if (model.detail.isEmpty && isFinish) {
      scanCount = 1;
      addPoiCount = 1;
      confirmPoiCount = 1;
    }

    // title
    title = isFinish ? '任务已完成' : S.of(context).task_failed;

    var isNotFinish = scanCount < 1 || addPoiCount < 1 || confirmPoiCount < 2;

    // detail
    if (isNotFinish && !isFinish) {
      detail = S.of(context).task_is_not_finish;
    }

    List<int> poiList = [];

    if ((confirmPOIModel?.state?.pois?.isNotEmpty ?? false) && !isFinish) {
      detail = S.of(context).false_data_at_location_detail_toast;

      var length = confirmPOIModel.state.pois.length;
      switch (length) {
        case 0:
          break;

        case 1:
          poiList = [0];
          break;

        case 2:
          poiList = [0, 4, 1];
          break;

        case 3:
          poiList = [0, 4, 1, 4, 2];
          break;

        default:
          poiList = [0, 4, 1, 4, 2];
          break;
      }
    }

    // 补充：判断是否是当天
    var today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    var isToday = today == model.day;
    //print("[v2] isToday:$isToday, today:$today, day:${model.day}, total:${model.total}");
    if (isToday && !isFinish && isNotFinish) {
      title = '进行中...';
      detail = S.of(context).you_still_have_unfinished_tasks_detail_toast;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    color: title == S.of(context).task_failed ? HexColor('#FF4C3B') : HexColor('#333333'),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Text(
                model.day,
                style: TextStyle(color: HexColor('#999999'), fontSize: 12),
              ),
            ],
          ),
          if (detail.isNotEmpty)
            Column(
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      detail,
                      style: TextStyle(color: HexColor('#333333'), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [1, 2, 3].map((value) {
                var title = "";
                var count = 0;
                bool isTrue = true;
                switch (value) {
                  case 1:
                    title = S.of(context).add_location;
                    isTrue = addPoiCount >= 1;
                    count = addPoiCount;
                    break;

                  case 2:
                    title = S.of(context).verification_location;
                    isTrue = confirmPoiCount >= 2;
                    if (model.detail.isEmpty && isFinish) {
                      isTrue = confirmPoiCount >= 1;
                    }

                    count = confirmPoiCount;
                    break;

                  case 3:
                    title = S.of(context).scanning_location;
                    isTrue = scanCount >= 1;
                    count = scanCount;
                    break;
                }

                if (isFinish && !isToday) {
                  isTrue = isFinish;
                }

                return Row(
                  children: <Widget>[
                    Image.asset(
                      isTrue ? "res/drawable/check_in_true.png" : "res/drawable/check_in_false.png",
                      width: 16,
                      height: 16,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "$title $count",
                      style: TextStyle(color: HexColor('#999999'), fontSize: 14),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (poiList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: poiList.map((value) {
                  CheckInModelPoi poi;
                  switch (value) {
                    case 0:
                    case 1:
                    case 2:
                      poi = confirmPOIModel.state.pois[value];
                      break;

                    case 4:
                      poi = null;
                      return Container(
                        height: 16,
                      );
                      break;
                  }

                  if (poi == null) {
                    return Container(
                      height: 0.01,
                    );
                  }
                  var createAt = DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(poi.createdAt * 1000));

                  return InkWell(
                    onTap: () {
                      if (poi?.detail?.isNotEmpty ?? false) {
                        _pushDetailView(poi);
                      }
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          //color: Colors.red,
                          child: Row(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'res/drawable/img_placeholder.jpg',
                                  image: poi.image.isNotEmpty ? poi.image : "",
                                  fit: BoxFit.cover,
                                  width: 98,
                                  height: 68,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            poi.name,
//                                          "唱唱",
                                            style: TextStyle(
                                                color: HexColor('#333333'), fontSize: 16, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
//                                        "6-3 12:02",
                                          createAt.isNotEmpty ? createAt : "",
                                          style: TextStyle(color: HexColor('#999999'), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
//                                        "美食/西餐",
                                          poi.category,
                                          style: TextStyle(color: HexColor('#333333'), fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Image.asset(
                                          "res/drawable/check_in_location.png",
                                          width: 12,
                                          height: 12,
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                          child: Text(
                                            //"广东省-广州市-天河区-黄埔大道西8号",
                                            poi.address.isNotEmpty ? poi.address : "",
                                            style: TextStyle(color: HexColor('#999999'), fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                            //maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 60,
                          top: 10,
                          child: Image.asset(
                            "res/drawable/check_in_fales_data_zh_CN.png",
                            width: 93,
                            height: 58,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Future<List> onLoadData(int page) async {
    return [];
    // PageResponse<CheckInModel> _pageResponse = await _userService.getHistoryListV3(page);
    // var dataList = _pageResponse.data;
    // return dataList;
  }

  _pushDetailView(CheckInModelPoi detail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeCheckInHistoryDetail(detail),
      ),
    );
  }
}
