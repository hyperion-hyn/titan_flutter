import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/node_mortgage_info.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/widget/smart_pull_refresh.dart';

class MyNodeMortgagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyNodeMortgageState();
  }
}

class _MyNodeMortgageState extends UserState<MyNodeMortgagePage> {
  static Color PRIMARY_COLOR = HexColor("#FF259B24");
  static Color GRAY_COLOR = HexColor("#9E101010");

  UserService _userService = UserService();

  PageResponse<NodeMortgageInfo> _nodeMortgagePage = PageResponse(0, 0, []);

  List nodeMortgageVoList = [];

  var currentPage = 0;

  @override
  void initState() {
    super.initState();
    _getNodeMortgageList(0);
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
      body: SafeArea(
        child: Column(
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
                      "总抵押",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "${Const.DOUBLE_NUMBER_FORMAT.format(LOGIN_USER_INFO.mortgageNodes)} USDT",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
//                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: SmartPullRefresh(
                        onRefresh: () {
                          _getNodeMortgageList(0);
                        },
                        onLoading: () {
                          _getNodeMortgageList(currentPage + 1);
                        },
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              return _buildNodeMortgageItem(nodeMortgageVoList[index]);
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Divider(
                                  thickness: 0.5,
                                  color: Colors.black12,
                                ),
                              );
                            },
                            itemCount: nodeMortgageVoList.length),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNodeMortgageItem(NodeMortgageVo nodeMortgageVo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Text(
                        nodeMortgageVo.title,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              if (nodeMortgageVo.subTitle != null)
                Text(
                  nodeMortgageVo.subTitle,
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
                  nodeMortgageVo.count,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Text(
                nodeMortgageVo.time,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )
            ],
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          ExtendsIconFont.redemption,
                          color: Colors.black54,
                        ),
                        title: Text("赎回抵押"),
                        onTap: () async {
                          try {
                            await _userService.redemption(id: nodeMortgageVo.id);
                            Navigator.of(context).pop();

                            await _getNodeMortgageList(0);
                            await getUserInfo();
                          } catch (e) {
                            logger.e(e);
                            Fluttertoast.showToast(msg: '赎回出错');
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.black12,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.close,
                          color: Colors.black54,
                        ),
                        title: Text("关闭"),
                        onTap: () {
                          //TODO 对接接口
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.more_vert,
                color: Colors.black54,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _getNodeMortgageList(int page) async {
    _nodeMortgagePage = await _userService.getNodeMortgageList(page);

    List<NodeMortgageVo> list = _nodeMortgagePage.data.map((nodeMortgageDetail) {
      return _covertNodeMortgageInfoToVo(nodeMortgageDetail);
    }).toList();
    if (list.length == 0) {
      return;
    }
    if (page == 0) {
      nodeMortgageVoList.clear();
      nodeMortgageVoList.addAll(list);
    } else {
      nodeMortgageVoList.addAll(list);
    }
    currentPage = page;
    if (mounted) {
      setState(() {});
    }
  }

  NodeMortgageVo _covertNodeMortgageInfoToVo(NodeMortgageInfo nodeMortgageInfo) {
    return NodeMortgageVo(
        iconColor: PRIMARY_COLOR,
        title: nodeMortgageInfo.name,
        subTitle: "抵押ID：${nodeMortgageInfo.id}",
        count: "${Const.DOUBLE_NUMBER_FORMAT.format(nodeMortgageInfo.amount)} USDT",
        time: "抵押时间：${Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(nodeMortgageInfo.createAt * 1000))}",
        id: nodeMortgageInfo.id);
  }
}

class NodeMortgageVo {
  Color iconColor;
  String title;
  String subTitle;
  String count;
  String time;
  int id;

  NodeMortgageVo({this.iconColor, this.title, this.subTitle, this.count, this.time, this.id});
}
