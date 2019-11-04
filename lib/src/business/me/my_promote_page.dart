import 'dart:math';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/promotion_info.dart';
import 'package:titan/src/business/me/promote_qr_code_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';

class MyPromotePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPromoteState();
  }
}

class _MyPromoteState extends DataListState<MyPromotePage> {
  UserService _userService = UserService();

//  PageResponse<PromotionInfo> _pageResponse = PageResponse(0, 0, []);

  String link = "${Const.MAP_RICH_DOMAIN_WEBSITE}register?code=${LOGIN_USER_INFO.id}";

  @override
  void postFrameCallBackAfterInitState() async {
    await _updateUserInstance();

    loadDataBloc.add(LoadingEvent());
  }

//  @override
//  void initState() {
//    super.initState();
//    _getFirstPromitionList();
//  }

  Future _updateUserInstance() async {
    try {
      LOGIN_USER_INFO = await _userService.getUserInfo();
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
//        backgroundColor: Colors.white,
        title: Text(
          "邀请分享",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: LoadDataContainer(
        bloc: loadDataBloc,
        onLoadData: onWidgetLoadDataCallback,
        onRefresh: onWidgetRefreshCallback,
        onLoadingMore: onWidgetLoadingMoreCallback,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.highestPower))}",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "最大星际量",
                              style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.lowPower))}",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "其他星际量",
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
                      children: <Widget>[Expanded(child: Text(link, style: TextStyle(color: Color(0xFF9B9B9B))))],
                    )
                  ],
                ),
              ),
            ),
            if (dataList.length > 1)
              SliverToBoxAdapter(
                child: Container(
                  color: Color(0xFFF8F8F8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      "已邀请${LOGIN_USER_INFO.totalInvitations}人",
                      style:
                          TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            if (dataList.length > 1)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildPromoteItem(context, dataList[index + 1]); //the first item is header;
                }, childCount: max<int>(0, dataList.length - 1)),
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(top: 96),
                  child: Column(
                    children: <Widget>[
                      Image.asset('res/drawable/empty_data.png', width: 100.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          '你还没成功邀请人~',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoteItem(context, promotion) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.perm_identity,
                  color: Color(0xFFB6B6B6),
                ),
                Text(
                  promotion.email,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(promotion.total))}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      "算力",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(promotion.highest))}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      "最大星际算力",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(promotion.low))}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      "其他星际算力",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
//            Divider(),
          ],
        ));
  }

  @override
  Future<List<dynamic>> onLoadData(int page) async {
    await _updateUserInstance();

    var retList = [];

    if (page == 0) {
      retList.add('header');
    }

    PageResponse<PromotionInfo> _pageResponse = await _userService.getPromotionList(page);
    retList.addAll(_pageResponse.data);

    return retList;
  }

//  Future _getFirstPromitionList() async {
//    await _getPromotionList(0);
//    setState(() {});
//  }
//
//  Future _getPromotionList(int page) async {
//    _pageResponse = await _userService.getPromotionList(page);
//  }

  void shareLink(String link) async {
    Share.text("我的邀请链接", "我的邀请链接：" + link, "text/plain");
//    await Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg');
  }
}
