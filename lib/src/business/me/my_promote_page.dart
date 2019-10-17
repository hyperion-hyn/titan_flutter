import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/promotion_info.dart';
import 'package:titan/src/business/me/promote_qr_code_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

class MyPromotePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPromoteState();
  }
}

class _MyPromoteState extends UserState<MyPromotePage> {
  UserService _userService = UserService();
  PageResponse<PromotionInfo> _pageResponse = PageResponse(0, 0, []);

  String link = "${Const.MAP_RICH_DOMAIN}register?code=${LOGIN_USER_INFO.id}";

  @override
  void initState() {
    super.initState();
    _getFirstPromitionList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
//        backgroundColor: Colors.white,
        title: Text(
          "我的推广",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.highPower)}",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "大区算力",
                            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.lowPower)}",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "小区算力",
                            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                          ),
                        ],
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                  Divider(
                    thickness: 0.5,
                    height: 48,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "邀请链接",
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: link));
                          Fluttertoast.showToast(msg: "邀请链接已复制");
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            ExtendsIconFont.copy_content,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PromoteQrCodePage(link)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            ExtendsIconFont.qr_code,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          shareLink(link);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            ExtendsIconFont.share,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(link, style: TextStyle(color: Color(0xFF9B9B9B))),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          if (_pageResponse.data.length > 0)
            SliverToBoxAdapter(
              child: Container(
                color: Color(0xFFF8F8F8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    "已邀请${LOGIN_USER_INFO.totalInvitations}人",
                    style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildPromoteItem(context, index);
            }, childCount: _pageResponse.data.length),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoteItem(context, index) {
    var _promotion = _pageResponse.data[index];
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.perm_identity,
                    color: Color(0xFFB6B6B6),
                  ),
                  Text(
                    _promotion.email,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(_promotion.total)}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      "他的算力",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(_promotion.high)}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      "他的大区算力",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(_promotion.low)}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      "他的小区算力",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
          ],
        ));
  }

  Future _getFirstPromitionList() async {
    await _getPromotionList(0);
    setState(() {});
  }

  Future _getPromotionList(int page) async {
    _pageResponse = await _userService.getPromotionList(page);
  }

  void shareLink(String link) async {
    Share.text("我的推广链接", "我的推广链接：" + link, "text/plain");
//    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg');
  }
}
