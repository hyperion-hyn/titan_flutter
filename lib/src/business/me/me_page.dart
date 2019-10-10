import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/me/buy_hash_rate_page.dart';
import 'package:titan/src/business/me/grade_page.dart';
import 'package:titan/src/business/me/model/common_response.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/my_hash_rate_page.dart';
import 'package:titan/src/business/me/my_node_mortgage_page.dart';
import 'package:titan/src/business/me/node_mortgage_page.dart';
import 'package:titan/src/business/me/personal_settings_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import 'my_asset_page.dart';
import 'my_promote_page.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeState();
  }
}

class _MeState extends UserState<MePage> with RouteAware {
  UserService _userService = UserService();

  int checkInCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCheckInCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }


  @override
  void didPopNext() {
    getUserInfo();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, left: 16, right: 16, bottom: 24),
              color: Theme.of(context).primaryColor,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage("res/drawable/default_avator.png"),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalSettingsPage()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Hi,${LOGIN_USER_INFO.email}",
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => GradePage()));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white70),
                                      shape: BoxShape.rectangle),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    child: Text(
                                      LOGIN_USER_INFO.level,
                                      style: TextStyle(fontSize: 10, color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Spacer(),
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white),
                                    shape: BoxShape.rectangle),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: Text(
                                    "打卡",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
//                                    color: Const.PRIMARY_COLOR,
                                    ),
                                  ),
                                )),
                            onTap: () {
                              _checkIn();
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "${checkInCount}/3",
                              style: TextStyle(color: Colors.white70),
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyAssetPage()));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.balance)} U",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              "我的资产",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white60,
                        width: 1,
                        height: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.totalPower)} POH",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              "算力",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white60,
                        width: 1,
                        height: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.mortgageNodes)} U",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              "节点抵押",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildCenterBigButton("获取算力", ExtendsIconFont.engine, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BuyHashRatePage()));
                    }),
                    _buildCenterBigButton("节点抵押", ExtendsIconFont.mortgage, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NodeMortgagePage()));
                    }),
                  ],
                ),
              ),
            ),
            _buildMemuBar("我的推广", ExtendsIconFont.promotion, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPromotePage()));
            }),
            SizedBox(
              height: 4,
            ),
            _buildMemuBar("使用教程", ExtendsIconFont.course, () {}),
//            _buildMemuBar("问题反馈", ExtendsIconFont.feedback, () {}),
//            _buildMemuBar("关于我们", ExtendsIconFont.about, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterBigButton(String title, IconData iconData, Function ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
//            border: Border.all(color: Colors.black38),
            shape: BoxShape.rectangle),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            children: <Widget>[
              Icon(
                iconData,
                color: Colors.black87,
                size: 42,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black54),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemuBar(String title, IconData iconData, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), shape: BoxShape.rectangle),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                iconData,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.black54,
            )
          ],
        ),
      ),
    );
  }

  Future _checkIn() async {
    try {
      await _userService.checkIn();
      checkInCount = await _userService.checkInCount();
      setState(() {});
      Fluttertoast.showToast(msg: "打卡成功");
    } catch (_) {
      Fluttertoast.showToast(msg: "打卡间隔低于30分钟");
    }
  }

  Future _updateCheckInCount() async {
    checkInCount = await _userService.checkInCount();
    setState(() {});
  }
}
