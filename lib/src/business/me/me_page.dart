import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
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
            Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 180,
                      color: Theme.of(context).primaryColor,
                    ),
                    Container(
                      height: 50,
                      color: Colors.white,
                    )
                  ],
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    elevation: 6,
                    color: Colors.transparent,
                    shadowColor: Colors.black87,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => PersonalSettingsPage()));
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Hi,${LOGIN_USER_INFO.email}",
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                                              border: Border.all(color: HexColor("#B4B4B4")),
                                              shape: BoxShape.rectangle),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            child: Text(
                                              LOGIN_USER_INFO.level,
                                              style: TextStyle(fontSize: 10, color: HexColor("#B4B4B4")),
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
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Theme.of(context).primaryColor),
                                            shape: BoxShape.rectangle),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                ExtendsIconFont.checkbox_outline,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              Text(
                                                " 打卡",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
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
                                      style: TextStyle(color: Theme.of(context).primaryColor),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.balance)}",
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "我的账户(USDT)",
                                      style: TextStyle(color: HexColor("#B4B4B4"), fontSize: 12),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.totalPower)}",
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "我的算力(T)",
                                      style: TextStyle(color: HexColor("#B4B4B4"), fontSize: 12),
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
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.mortgageNodes)}",
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "节点抵押(USDT)",
                                      style: TextStyle(color: HexColor("#B4B4B4"), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _buildCenterBigButton("获取算力", "res/drawable/get_power.png", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BuyHashRatePage()));
                      }),
                      VerticalDivider(),
                      _buildCenterBigButton("节点抵押", "res/drawable/node_mortgage.png", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NodeMortgagePage()));
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: HexColor("#E9E9E9"))),
              child: Column(
                children: <Widget>[
                  _buildMemuBar("我的推广", ExtendsIconFont.mail_read, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyPromotePage()));
                  }),
                  Divider(
                    height: 2,
                  ),
                  _buildMemuBar("使用教程", ExtendsIconFont.document, () {}),
                  Divider(
                    height: 2,
                  ),
                  _buildMemuBar("关于我们", ExtendsIconFont.person, () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCenterBigButton(String title, String imageAsset, Function ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 52),
          child: Row(
            children: <Widget>[
              Image.asset(
                imageAsset,
                width: 42,
                height: 42,
                color: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                iconData,
                color: HexColor("#B4B4B4"),
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
