import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/power_detail.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';

class MyHashRatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHashRateState();
  }
}

class _MyHashRateState extends DataListState<MyHashRatePage> {
  UserService _userService = UserService();

  static Color PRIMARY_COLOR = HexColor("#FF259B24");
  static Color GRAY_COLOR = HexColor("#9E101010");

//  LOGIN_USER_INFO = await _userService.getUserInfo();
//  List hashRateList = [];
//  int currentPage = 0;

  static DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd");

//  @override
//  void initState() {
//    super.initState();
//    _getPowerList(0);
//  }

  @override
  void postFrameCallBackAfterInitState() async {
    loadDataBloc.add(LoadingEvent());

    try {
      LOGIN_USER_INFO = await _userService.getUserInfo();
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
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
                    "我的总算力",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.totalPower))} T",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LoadDataContainer(
                        bloc: loadDataBloc,
                        onLoadData: onWidgetLoadDataCallback,
                        onRefresh: onWidgetRefreshCallback,
                        onLoadingMore: onWidgetLoadingMoreCallback,
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              return _buildHashRateItem(dataList[index]);
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(
                                thickness: 0.5,
                                color: Colors.black12,
                              );
                            },
                            itemCount: dataList.length),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHashRateItem(HashRateVo hashRateVo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Text(
                      hashRateVo.title,
                      style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                    ),
                  ],
                ),
              ),
              if (hashRateVo.subTitle != null)
                Text(
                  hashRateVo.subTitle,
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
                  hashRateVo.validity,
                  style: TextStyle(fontSize: 14, color: hashRateVo.validityColor),
                ),
              ),
              Text(
                hashRateVo.time,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Future<List<dynamic>> onLoadData(int page) async {
    PageResponse<PowerDetail> powerPageResponse = await _userService.getPowerList(page);

    return powerPageResponse.data.map((powerDetail) {
      return _convertPowerDetailToHashRateVo(powerDetail);
    }).toList();
  }

  HashRateVo _convertPowerDetailToHashRateVo(PowerDetail powerDetail) {
    var iconColor = powerDetail.expire ? Color(0xFF6D6D6D) : Color(0xFF6DBA1A);
    var validity = powerDetail.expire ? "已结束" : "有效";
    var validityColor = powerDetail.expire ? Color(0xFF6D6D6D) : Color(0xFF6DBA1A);

    var createAt = DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(powerDetail.createdAt * 1000));
    var expiredAt = DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(powerDetail.expiredAt * 1000));

    var time = "$createAt ~ $expiredAt";
    return HashRateVo(
        iconData: ExtendsIconFont.engine,
        iconColor: iconColor,
        title: "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(powerDetail.power))} T",
        subTitle: "合约ID：${powerDetail.contractId}",
        validity: validity,
        validityColor: validityColor,
        time: time);
  }
}

class HashRateVo {
  IconData iconData;
  Color iconColor;
  String title;
  String subTitle;
  String validity;
  Color validityColor;
  String time;

  HashRateVo({this.iconData, this.iconColor, this.title, this.subTitle, this.validity, this.validityColor, this.time});
}
