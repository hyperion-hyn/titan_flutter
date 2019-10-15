import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/mortgage_info.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import 'mortgage_page.dart';

class NodeMortgagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeMortgageState();
  }
}

class _NodeMortgageState extends State<NodeMortgagePage> {
  UserService _userService = UserService();

  List<MortgageInfo> mortgageList = [];

  @override
  void initState() {
    super.initState();
    _getMortgageList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "节点抵押",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
//        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Material(
              child: Container(
                color: Color(0xFFFFF8EA),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "节点抵押，随进随出，不限时间。",
                  style: TextStyle(color: Color(0xFFCE9D40)),
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return _buildItem(mortgageList[index]);
          }, childCount: mortgageList.length))
        ],
      ),
    );
  }

  Widget _buildItem(MortgageInfo mortgageInfo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image.asset(
                    "res/drawable/node_icon.png",
                    width: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      mortgageInfo.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Spacer(),
                  Text(
                    "",
                    style: TextStyle(color: Color(0xFF6D6D6D)),
                  )
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.black12,
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(mortgageInfo.amount)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "抵押所需(USDT)",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        mortgageInfo.incomeRate,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "30天收益(USDT)",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 24,
              ),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MortgagePage(mortgageInfo)));
                },
                child: SizedBox(
                  width: 172,
                  height: 40,
                  child: Center(
                    child: Text(
                      "我要抵押",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _getMortgageList() async {
    mortgageList = await _userService.getMortgageList();
    setState(() {});
  }
}
