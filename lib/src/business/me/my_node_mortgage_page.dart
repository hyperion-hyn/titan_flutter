import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/business/load_data_container/bloc/bloc.dart';
import 'package:titan/src/business/load_data_container/load_data_container.dart';
import 'package:titan/src/business/me/model/node_mortgage_info.dart';
import 'package:titan/src/business/me/model/page_response.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import 'enter_fund_password.dart';

class MyNodeMortgagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyNodeMortgageState();
  }
}

class _MyNodeMortgageState extends DataListState<MyNodeMortgagePage> {
  static Color PRIMARY_COLOR = HexColor("#FF259B24");
  static Color GRAY_COLOR = HexColor("#9E101010");

  UserService _userService = UserService();


  @override
  void postFrameCallBackAfterInitState() async {
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
                    S.of(context).my_node_mortgage,
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
                    child: LoadDataContainer(
                      bloc: loadDataBloc,
                      onLoadData: onWidgetLoadDataCallback,
                      onRefresh: onWidgetRefreshCallback,
                      onLoadingMore: onWidgetLoadingMoreCallback,
                      child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            return _buildNodeMortgageItem(dataList[index]);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              thickness: 0.5,
                              color: Colors.black12,
                            );
                          },
                          itemCount: dataList.length),
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
                        title: Text(S.of(context).redemption_mortgage),
                        onTap: () async {
                          try {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return EnterFundPasswordWidget();
                                }).then((fundToken) async {
                              if (fundToken == null) {
                                return;
                              }
                              await _userService.redemption(id: nodeMortgageVo.id, fundToken: fundToken);
                              Navigator.pop(context, true);
                              Fluttertoast.showToast(msg: S.of(context).redemption_success);

                              loadDataBloc.add(LoadingEvent());
                            });
                          } catch (e) {
                            logger.e(e);
                            Fluttertoast.showToast(msg: S.of(context).redemption_fail);
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
                        title: Text(S.of(context).close),
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

  @override
  Future<List<dynamic>> onLoadData(int page) async {
    //刷新金额
    _updateUserInstance();

    PageResponse<NodeMortgageInfo> _nodeMortgagePage = await _userService.getNodeMortgageList(page);

    return _nodeMortgagePage.data.map((nodeMortgageDetail) {
      return _covertNodeMortgageInfoToVo(nodeMortgageDetail);
    }).toList();
  }


  NodeMortgageVo _covertNodeMortgageInfoToVo(NodeMortgageInfo nodeMortgageInfo) {
    return NodeMortgageVo(
        iconColor: PRIMARY_COLOR,
        title: nodeMortgageInfo.name,
        subTitle: S.of(context).mortgage_id(nodeMortgageInfo.id.toString()),
        count: "${Const.DOUBLE_NUMBER_FORMAT.format(nodeMortgageInfo.amount)} USDT",
        time: S.of(context).mortgage_time(
            Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(nodeMortgageInfo.createAt * 1000))),
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
