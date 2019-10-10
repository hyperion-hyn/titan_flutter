import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/my_node_mortgage_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';

import 'model/mortgage_info.dart';

class MortgagePage extends StatefulWidget {
  final MortgageInfo mortgageInfo;

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
        title: Text('节点抵押'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  color: Color(0xfff6f6f6),
                  shape: BoxShape.rectangle),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "产品：",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text("${widget.mortgageInfo.name}"),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "合计：",
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text("${Const.DOUBLE_NUMBER_FORMAT.format(widget.mortgageInfo.amount)} U")
                    ],
                  )
                ],
              ),
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
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(color: HexColor("#fff5f4fa"), shape: BoxShape.rectangle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "余额",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  Text(
                    "${userInfo?.balance} U",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "将支付",
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        '${widget.mortgageInfo?.amount}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'U',
                      ),
                    ),
                  ],
                ),
              ),
              RaisedButton(
                elevation: 10,
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  if (widget.mortgageInfo != null && userInfo != null) {
                    if (userInfo.balance < widget.mortgageInfo.amount) {
                      Fluttertoast.showToast(msg: '余额不足');
                    } else {
                      try {
                        await service.mortgage(confId: widget.mortgageInfo.id);
                        Fluttertoast.showToast(msg: '抵押成功');
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                      } catch (e) {
                        logger.e(e);
                        Fluttertoast.showToast(msg: '抵押异常');
                      }
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    "确认抵押",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
//        Container(
//          margin: EdgeInsets.only(top: 8),
//          padding: EdgeInsets.symmetric(vertical: 8.0),
//          child: Row(
//            children: <Widget>[
//              Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: Icon(
//                  Icons.notification_important,
//                  color: Colors.grey,
//                  size: 20,
//                ),
//              ),
//              Expanded(
//                child: Text(
//                  "当前 U 兑换 HYN 的汇率为: 1U = 3.3HYN",
//                  style: TextStyle(color: Colors.grey, fontSize: 12),
//                  softWrap: true,
//                ),
//              )
//            ],
//          ),
//        )
      ],
    );
  }
}
