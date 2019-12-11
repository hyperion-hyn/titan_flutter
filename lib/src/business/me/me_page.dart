import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/about/about_me_page.dart';
import 'package:titan/src/business/me/grade_page.dart';
import 'package:titan/src/business/me/my_hash_rate_page.dart';
import 'package:titan/src/business/me/my_node_mortgage_page.dart';
import 'package:titan/src/business/me/node_mortgage/node_mortgage_page_v2.dart';
import 'package:titan/src/business/me/personal_settings_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/business/my_encrypted_addr/my_encrypted_addr_page.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/utils.dart';
import 'me_check_in_page.dart';
import 'contract/buy_hash_rate_page_v2.dart';
import 'my_asset_page.dart';
import 'my_promote_page.dart';
import 'me_checkin_history_page.dart';
import 'me_setting_page.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeState();
  }
}

class _MeState extends UserState<MePage> with RouteAware {
  UserService _userService = UserService();

  int checkInCount = 0;

  String _pubKey = "";

  @override
  void initState() {
    super.initState();
    _updateCheckInCount();

    _loadData();
  }

  Future _loadData() async {
    _pubKey = await TitanPlugin.getPublicKey();
    setState(() {});
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
                                      "${shortEmail(LOGIN_USER_INFO.email)}",
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
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text(
                                              LOGIN_USER_INFO.level == ""
                                                  ? S.of(context).no_level
                                                  : LOGIN_USER_INFO.level,
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
                                                checkInCount >= 3 ? S.of(context).finish : S.of(context).task,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    onTap:
//                                    checkInCount < 3
//                                        ? () {
                                        _checkIn,
//                                          }
//                                        : () {
//                                      Fluttertoast.showToast(msg: '今天任务已完成');
//                                          },
//                                    onTap: _checkIn,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "$checkInCount/3",
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
                                      S.of(context).my_account_with_unit,
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
                                      "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.totalPower))}",
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      S.of(context).my_power_with_unit,
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
                                      S.of(context).node_mortgage_with_unit,
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
                      _buildCenterBigButton(S.of(context).get_power, "res/drawable/get_power.png", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BuyHashRatePageV2()));
                      }),
                      VerticalDivider(),
                      _buildCenterBigButton(S.of(context).node_mortgage, "res/drawable/node_mortgage.png", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NodeMortgagePageV2()));
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: HexColor("#E9E9E9"), width: 0)),
              child: Column(
                children: <Widget>[
                  // todo: jison opened
                  _buildMemuBar(S.of(context).task_record, ExtendsIconFont.check_in, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MeCheckInHistory()));
                  }),
                  Divider(
                    height: 2,
                  ),

                  _buildMemuBar(S.of(context).invite_share, ExtendsIconFont.mail_read, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyPromotePage()));
                  }),
                  Divider(
                    height: 2,
                  ),

                  _buildMemuBar(S.of(context).use_guide, ExtendsIconFont.document, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebViewContainer(
                                  initUrl: "https://www.maprich.net/intro",
                                  title: S.of(context).use_guide,
                                )));
                  }),


                  Divider(
                    height: 2,
                  ),

                  _buildMemuBar(S.of(context).setting, ExtendsIconFont.setting, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MeSettingPage()));
                  }),

                  Divider(
                    height: 2,
                  ),

                  _buildMemuBar(S.of(context).about_us, ExtendsIconFont.person, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()));
                  }),

                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Divider(
              height: 0,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 16),
                    child: Text(
                      S.of(context).dmap_setting,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildDappItem(ExtendsIconFont.point, S.of(context).private_sharing,
                      S.of(context).private_share_receive_address(shortEthAddress(_pubKey)), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
                  }),
                ],
              ),
            ),
            Divider(
              height: 0,
            ),
            SizedBox(
              height: 16,
            ),
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
          padding: const EdgeInsets.symmetric(vertical: 52),
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

  Widget _buildDappItem(IconData iconData, String title, String description, Function ontap) {
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 8, bottom: 8, right: 16),
              child: Center(child: Icon(iconData, color: HexColor("#B4B4B4"), size: 24))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Spacer(),
          Icon(
            Icons.chevron_right,
            color: Colors.black54,
          )
        ],
      ),
    );
  }

  Future _checkIn() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => MeCheckIn()));
    _checkIn1();
  }

  Future _checkIn1() async {
    try {
      await _userService.checkIn();
      checkInCount = await _userService.checkInCount();
      setState(() {});
      Fluttertoast.showToast(msg: S.of(context).thank_you_for_contribute_data);
    } catch (e) {
      print('[me_page] --> e:$e');

      ExceptionProcess.process(e);
      throw e;
    }
  }

  Future _updateCheckInCount() async {
    try {
      checkInCount = await _userService.checkInCount();
      setState(() {});
    } catch (_) {
      ExceptionProcess.process(_);
      throw _;
    }
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }
}
