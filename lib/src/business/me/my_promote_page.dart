import 'dart:math';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/promotion_info.dart';
import 'package:titan/src/business/me/promote_qr_code_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/consts/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';

class MyPromotePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPromoteState();
  }
}

class _MyPromoteState extends DataListState<MyPromotePage> {
  UserService _userService = UserService();

  String link = "${Const.MAP_RICH_DOMAIN_WEBSITE}register?lang=${getRequestLang()}&code=${LOGIN_USER_INFO.id}";

  @override
  void postFrameCallBackAfterInitState() async {
    await _updateUserInstance();

    loadDataBloc.add(LoadingEvent());
  }


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
          S.of(context).invite_share,
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
                    // todo: jison edit_星际数
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              S.of(context).star_number,
                              style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.numOfTeamMember)}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              S.of(context).direct_star_numbers,
                              style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.directlyPower))}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              S.of(context).max_star_numbers,
                              style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.highestPower))}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              S.of(context).other_star_numbers,
                              style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(LOGIN_USER_INFO.lowPower))}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      children: <Widget>[
                        GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage("res/drawable/default_avator.png"),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Text(
                            S.of(context).by_recommend('${getParentEmail()}'),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                    Divider(
                      thickness: 0.5,
                      height: 48,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          S.of(context).invite_link,
                          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: link));
                            Fluttertoast.showToast(msg: S.of(context).invite_link_copy_hint);
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
                        /*
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
                        */
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
                      S.of(context).total_invitation_func('${LOGIN_USER_INFO.totalInvitations}'),
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
                          S.of(context).no_invite_success_hint,
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
                // todo: jison edit_团队注册量
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(promotion.numOfTeamMember)}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      S.of(context).star_number,
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(Utils.powerForShow(promotion.directlyPower))}",
                        style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      S.of(context).direct_star_numbers,
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
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
                      S.of(context).max_star_numbers,
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
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
                      S.of(context).other_star_numbers,
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
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

  String getParentEmail() {
    if (LOGIN_USER_INFO.parentUser != null) {
      if (LOGIN_USER_INFO.parentUser.email != null) {
        return LOGIN_USER_INFO?.parentUser.email;
      }
      return LOGIN_USER_INFO.email;
    }
    return LOGIN_USER_INFO.email;
  }

  void shareLink(String link) async {
    Share.text("我的邀请链接", "我的邀请链接：" + link, "text/plain");
    //await Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg');
  }
}
