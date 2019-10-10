import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/model/promotion_info.dart';
import 'package:titan/src/business/me/model/user_info.dart';
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

  @override
  void initState() {
    super.initState();
    _getFirstPromitionList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("我的推广"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
//            margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(border: Border.all(color: Colors.black12), color: Colors.white),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      columnWidths: {
                        0: FractionColumnWidth(.3),
                        1: FractionColumnWidth(.7),
                      },
                      children: [
                        TableRow(children: [
                          Text(
                            "我的大区算力",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.highPower)} POH",
                            style: TextStyle(fontSize: 16),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "我的小区算力",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.lowPower)} POH",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ]),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.5,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("我的邀请链接", style: TextStyle(color: Colors.black54)),
                      Column(
                        children: <Widget>[
                          QrImage(
                            data: "https://www.baidu.com/cfefewfeaf",
                            backgroundColor: Colors.white,
                            version: 2,
                            size: 120,
                          ),
                          Row(
                            children: <Widget>[
                              Text("https://xxxxx/cfefewfeaf", style: TextStyle(color: Colors.black54)),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  Icons.content_copy,
                                  color: Colors.black54,
                                  size: 16,
                                ),
                              )
                            ],
                          ),
                          FlatButton(
                            onPressed: () {
                              //TODO share
                            },
                            child: Text(
                              "分享邀请",
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "已邀请${LOGIN_USER_INFO.totalInvitations}人",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
        margin: EdgeInsets.only(bottom: 1),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _promotion.email,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              columnWidths: {
                0: FractionColumnWidth(.3),
                1: FractionColumnWidth(.7),
              },
              children: [
                TableRow(children: [
                  Text(
                    "他的算力",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text("${Const.DOUBLE_NUMBER_FORMAT.format(_promotion.total)} POH")
                ]),
                TableRow(children: [
                  Text(
                    "他的大区算力",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text("${Const.DOUBLE_NUMBER_FORMAT.format(_promotion.high)} POH")
                ]),
                TableRow(children: [
                  Text(
                    "他的小区算力",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text("${Const.DOUBLE_NUMBER_FORMAT.format(_promotion.low)} POH")
                ]),
              ],
            ),
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
}
