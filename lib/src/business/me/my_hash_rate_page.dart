import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/power_detail.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/widget/smart_pull_refresh.dart';

class MyHashRatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHashRateState();
  }
}

class _MyHashRateState extends UserState<MyHashRatePage> {
  static Color PRIMARY_COLOR = HexColor("#FF259B24");
  static Color GRAY_COLOR = HexColor("#9E101010");

  UserService _userService = UserService();

  PageResponse<PowerDetail> powerPageResponse = PageResponse(0, 0, []);

  List hashRateList = [];

  static DateFormat DATE_FORMAT = new DateFormat("yy/MM/dd");
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _getPowerList(0);
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
                    "总算力",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.totalPower)} T",
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
                      child: SmartPullRefresh(
                        onRefresh: () {
                          _getPowerList(0);
                        },
                        onLoading: () {
                          _getPowerList(currentPage + 1);
                        },
                        child: SmartPullRefresh(
                          onRefresh: () {
                            _getPowerList(0);
                          },
                          onLoading: () {
                            _getPowerList(currentPage + 1);
                          },
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                return _buildHashRateItem(hashRateList[index]);
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return Divider(
                                  thickness: 0.5,
                                  color: Colors.black12,
                                );
                              },
                              itemCount: hashRateList.length),
                        ),
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
                  style: TextStyle(fontSize: 14, color: Colors.black54),
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
                  style: TextStyle(fontSize: 16, color: hashRateVo.validityColor),
                ),
              ),
              Text(
                hashRateVo.time,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              )
            ],
          )
        ],
      ),
    );
  }

  Future _getPowerList(int page) async {
    powerPageResponse = await _userService.getPowerList(page);

    List<HashRateVo> list = powerPageResponse.data.map((powerDetail) {
      return _convertPowerDetailToHashRateVo(powerDetail);
    }).toList();

    if (list.length == 0) {
      return;
    }

    if (page == 0) {
      hashRateList.clear();
      hashRateList.addAll(list);
    } else {
      hashRateList.addAll(list);
    }

    currentPage = page;
    if (mounted) {
      setState(() {});
    }
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
        title: "${powerDetail.power} T",
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
