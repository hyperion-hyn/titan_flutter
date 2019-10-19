import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/my_node_mortgage_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';

import 'enter_fund_password.dart';
import 'model/mortgage_info.dart';
import 'model/mortgage_info_v2.dart';

class MortgagePage extends StatefulWidget {
  final MortgageInfoV2 mortgageInfo;

  MortgagePage(this.mortgageInfo);

  @override
  State<StatefulWidget> createState() {
    return _MortgagePageState();
  }
}

class _MortgagePageState extends State<MortgagePage> {
  var service = UserService();
  UserInfo userInfo;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var _userInfo = await service.getUserInfo();
    setState(() {
      userInfo = _userInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
//        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '抵押支付',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "抵押产品：${widget.mortgageInfo.name}",
                        style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "金额：${Const.DOUBLE_NUMBER_FORMAT.format(widget.mortgageInfo.amount)} USDT",
                      style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 16),
            _buildBalancePayBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancePayBox() {
    return Column(
      children: <Widget>[
        Material(
          elevation: 3,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "请抵押",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '${Const.DOUBLE_NUMBER_FORMAT.format(widget.mortgageInfo?.amount ?? 0)} USDT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFFCE9D40)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '收益余额：',
                        style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                      ),
                      Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(userInfo == null ? 0 : userInfo.balance - userInfo.chargeBalance)} USDT",
                        style: TextStyle(fontSize: 16, color: Color(0xFF9B9B9B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 32,
        ),
        RaisedButton(
          elevation: 1,
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            if (widget.mortgageInfo != null && userInfo != null) {
              if (userInfo.balance - userInfo.chargeBalance < widget.mortgageInfo.amount) {
                Fluttertoast.showToast(msg: '可用于抵押的余额不足');
              } else {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return EnterFundPasswordWidget();
                    }).then((fundToken) async {
                  if (fundToken == null) {
                    return;
                  }
                  try {
                    await service.mortgage(confId: widget.mortgageInfo.id, fundToken: fundToken);
                    Fluttertoast.showToast(msg: '抵押成功');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                  } catch (e) {
                    logger.e(e);
                    Fluttertoast.showToast(msg: '抵押异常');
                  }
                });
              }
            }
          },
          child: SizedBox(
            width: 192,
            height: 56,
            child: Center(
              child: Text(
                "确认抵押",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 64.0),
          child: Text(
            '提示：只能使用收益余额进行节点抵押支付',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
