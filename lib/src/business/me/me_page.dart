import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/about/about_me_page.dart';
import 'package:titan/src/business/home/data_contribution_page.dart';
import 'package:titan/src/business/me/grade_page.dart';
import 'package:titan/src/business/me/my_hash_rate_page.dart';
import 'package:titan/src/business/me/my_node_mortgage_page.dart';
import 'package:titan/src/business/me/node_mortgage/node_mortgage_page_v2.dart';
import 'package:titan/src/business/me/personal_settings_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/business/my/me_setting_page.dart';
import 'package:titan/src/business/my_encrypted_addr/my_encrypted_addr_page.dart';
import 'package:titan/src/business/webview/inappwebview.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/consts/extends_icon_font.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:titan/src/utils/utils.dart';
import 'contract/buy_hash_rate_page_v2.dart';
import 'my_asset_page.dart';
import 'my_promote_page.dart';
import 'me_checkin_history_page.dart';

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
    _updateCheckInCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeaderSection(),
            _buildPohNodeSection(),
            _dividerView(isBottom: true),
            _buildSettingSection(),
            _dividerView(),
            _buildShareSection(),
            _dividerView(isBottom: true),
          ],
        ),
      ),
    );
  }

  Widget _dividerView({bool isBottom = false}) {
    if (isBottom) {
      return Column(
        children: <Widget>[
          Divider(
            height: 0,
          ),
          SizedBox(
            height: 16 * 1.0,
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      children: <Widget>[
        Container(
          height: 230,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [HexColor('#CC941E'), HexColor('#E4B042'), HexColor('#FBE6BD')],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    child: Stack(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage("res/drawable/default_avator.png"),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Image.asset(
                            'res/drawable/ic_me_page_use_edit.png',
                            width: 12,
                            height: 12,
                            color: Colors.yellow,
                          ),
                        )
                      ],
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                                  border: Border.all(color: HexColor("#DADFE4")),
                                  shape: BoxShape.rectangle),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  LOGIN_USER_INFO.level == ""
                                      ? S.of(context).no_level
                                      : LOGIN_USER_INFO.level,
                                  style: TextStyle(fontSize: 10, color: HexColor("#F9F9F9")),
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
                                color: HexColor('#F2C345'),
                                borderRadius: BorderRadius.circular(16),
                                //border: Border.all(color: Theme.of(context).primaryColor),
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
                                    checkInCount >= 3
                                        ? S.of(context).check_in_completed
                                        : S.of(context).task,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        onTap: _checkIn,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "$checkInCount/3",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [HexColor('#AC823A'), HexColor('#EDC67B'), HexColor('#CBAA69')],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildHeaderSectionItem(S.of(context).my_account_with_unit, LOGIN_USER_INFO.balance, (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => MyAssetPage()));
                    }),
                    _buildHeaderSectionItem(S.of(context).my_power_with_unit, LOGIN_USER_INFO.totalPower, (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                    }),
                    _buildHeaderSectionItem(S.of(context).node_mortgage_with_unit, LOGIN_USER_INFO.mortgageNodes, (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeaderSectionItem(String title, dynamic count, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "${Const.DOUBLE_NUMBER_FORMAT.format(count)}",
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 3,),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPohNodeSection() {
    return Container(
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
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: VerticalDivider(width: 0.5, color: HexColor('#E9E9E9'),),
              ),
              _buildCenterBigButton(S.of(context).node_mortgage, "res/drawable/node_mortgage.png", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NodeMortgagePageV2()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: HexColor("#E9E9E9"), width: 0)),
      child: Column(
        children: <Widget>[
          // todo: jison opened
          _buildMemuBar(S.of(context).task_record, "ic_me_page_task_record", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MeCheckInHistory()));
          }),
          Divider(
            height: 2,
          ),

          _buildMemuBar(S.of(context).invite_share, "ic_me_page_invite_share", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPromotePage()));
          }),
          Divider(
            height: 2,
          ),

          _buildMemuBar(S.of(context).use_guide, "ic_me_page_use_guide", () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InAppWebViewContainer(
                      initUrl: S.of(context).maprich_intro_url(Const.MAP_RICH_DOMAIN_WEBSITE),
                      title: S.of(context).use_guide,
                    )));
          }),

          Divider(
            height: 2,
          ),

          _buildMemuBar(S.of(context).setting, "ic_me_page_setting", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MeSettingPage()));
          }),

          Divider(
            height: 2,
          ),

          _buildMemuBar(S.of(context).about_us, "ic_me_page_about_us", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AboutMePage()));
          }),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Container(
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
          _buildDappItem('ic_me_page_use_location', S.of(context).private_sharing,
              S.of(context).private_share_receive_address(shortEthAddress(_pubKey)), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyEncryptedAddrPage()));
              }),
        ],
      ),
    );
  }

  Widget _buildCenterBigButton(String title, String imageAsset, Function ontap) {
    return InkWell(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 48, bottom: 29),
          child: Row(
            children: <Widget>[
              Image.asset(
                imageAsset,
                width: 42,
                height: 42,
                //color: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: TextStyle(color: HexColor("#333333"), fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemuBar(String title, String iconData, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            Container(
              width: 20,
              height: 20,
              child: Image.asset("res/drawable/$iconData.png",fit: BoxFit.contain,),
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

  Widget _buildDappItem(String iconData, String title, String description, Function ontap) {
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 8, bottom: 8, right: 16),
              width: 19,
              height: 27,
              child: Image.asset("res/drawable/$iconData.png",fit: BoxFit.contain,),
          ),
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
    await Navigator.push(
        context,
        MaterialPageRoute(
            settings: RouteSettings(name: '/data_contribution_page'), builder: (context) => DataContributionPage()));
//    _finishCheckIn();
  }

  Future _updateCheckInCount() async {
    try {
      globalCheckInModel = await _userService.checkInCountV2();
//      checkInCount = await _userService.checkInCount();
      setState(() {
        checkInCount = globalCheckInModel?.finishTaskNum ?? 0;
      });
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
