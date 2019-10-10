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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("节点列表"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Material(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "提示：节点抵押，随进随出，不限时间。",
                  style: TextStyle(color: Colors.black54),
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
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), color: Colors.white),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(ExtendsIconFont.mortgage),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  mortgageInfo.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Spacer(),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MortgagePage(mortgageInfo)));
                },
                child: Text(
                  "我要抵押",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          Divider(
            thickness: 0.5,
            color: Colors.black12,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 88,
                child: Text(
                  "抵押所需",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              Text(
                "${Const.DOUBLE_NUMBER_FORMAT.format(mortgageInfo.amount)} U",
              )
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 88,
                child: Text(
                  "30天收益",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              Text(
                mortgageInfo.incomeRate,
              )
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 88,
                child: Text(
                  "结算方式",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              Text(
                "每日返还",
              )
            ],
          )
        ],
      ),
    );
  }

  Future _getMortgageList() async {
    mortgageList = await _userService.getMortgageList();
    setState(() {});
  }
}
