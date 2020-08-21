import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class AtlasStakeSelectPage extends StatefulWidget {
  AtlasStakeSelectPage();

  @override
  State<StatefulWidget> createState() {
    return _AtlasStakeSelectPageState();
  }
}

class _AtlasStakeSelectPageState extends State<AtlasStakeSelectPage> {
  var infoTitleList = ["总抵押", "签名率", "最近回报率", "总抵押11", "签名率11", "最近回报率11"];
  var infoContentList = ["12930903", "98%", "11.23%1", "129309031", "98%1", "11.23%1"];
  bool isShowAll = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "抵押Atlas节点",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 18,
                  ),
                  stakeHeaderInfo(context),
                  Padding(
                    padding: const EdgeInsets.only(top: 19.0, bottom: 7),
                    child: Divider(
                      color: DefaultColors.colorf2f2f2,
                      height: 0.5,
                      indent: 14,
                      endIndent: 14,
                    ),
                  ),
                  stakeInfoView(infoTitleList, infoContentList, isShowAll, () {
                    setState(() {
                      isShowAll = true;
                    });
                  }),
                  _map3NodeSelection(),
                  Container(
                    height: 10,
                    color: HexColor("#F2F2F2"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 14, top: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("注意事项", style: TextStyles.textC333S16),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text("· 抵押后下一个纪元当选才会产生收益"),
                        ),
                        Text("· 撤销抵押需要等下一个纪元才能生效，期间可以继续享受出块收益回报"),
                      ],
                    ),
                  ),
                ],
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 36.0, top: 22),
              child: ClickOvalButton(
                S.of(context).confirm,
                () {},
                width: 300,
                height: 46,
              ),
            )
          ],
        ));
  }

  _map3NodeSelection() {
    var _selectedMap3NodeValue = 'map3Node1';
    List<DropdownMenuItem> _map3NodeItems = List();
    _map3NodeItems.add(
      DropdownMenuItem(
        value: 'map3Node1',
        child: Text(
          'Lance的Map3节点-1',
          style: TextStyles.textC333S14,
        ),
      ),
    );
    _map3NodeItems.add(
      DropdownMenuItem(
        value: 'map3Node2',
        child: Text(
          'Lance的Map3节点-2',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('选择需要抵押的Map3节点',style: TextStyles.textC333S14,),
          SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: HexColor('#F2F2F2'),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 13,right: 13),
              child: DropdownButtonFormField(
                icon: Image.asset("res/drawable/ic_arrow_down.png",width: 14,height: 14,),
                decoration: InputDecoration(
                    border: InputBorder.none),
                onChanged: (value) {
                  setState(() {
                    _selectedMap3NodeValue = value;
                  });
                },
                value: _selectedMap3NodeValue,
                items: _map3NodeItems,
              ),
            ),
          )
        ],
      ),
    );
  }

}

Widget stakeHeaderInfo(BuildContext buildContext) {
  return Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 14.0, right: 8),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network("http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png",
                fit: BoxFit.cover, width: 44, height: 44)),
      ),
      Expanded(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "派大星",
                  style: TextStyles.textC333S16,
                ),
                Spacer(),
                Container(
                    padding: EdgeInsets.only(left: 6.0, right: 6),
                    color: HexColor("#e3fafb"),
                    child: Text("出块节点", style: TextStyles.textC333S12)),
              ],
            ),
            Row(
              children: <Widget>[
                Text("节点地址 1231231231", style: TextStyles.textC999S11),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: "abc"));
                    UiUtil.toast(S.of(buildContext).copyed);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8, top: 3, bottom: 3),
                    child: Image.asset(
                      "res/drawable/ic_copy.png",
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  "节点号：111",
                  style: TextStyles.textC333S12,
                ),
              ],
            )
          ],
        ),
      ),
      SizedBox(
        width: 14,
      )
    ],
  );
}

Widget stakeInfoView(List<String> infoTitleList, List<String> infoContentList, bool isShowAll, Function showAllInfo) {
  return Column(
    children: <Widget>[
      Column(
        children: List.generate(
            isShowAll ? infoTitleList.length : 3,
                (index) => Padding(
                  padding: const EdgeInsets.only(top:9.0,bottom: 9),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            infoTitleList[index],
                            style: TextStyle(fontSize: 14, color: HexColor("#999999")),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Text(infoContentList[index], style: TextStyle(fontSize: 14, color: HexColor("#333333")),),
                        ),
                      )
                    ],
                  ),
                )).toList(),
      ),
      if (!isShowAll)
        InkWell(
            onTap: () {
              showAllInfo();
            },
            child: Padding(
              padding: const EdgeInsets.only(top:7.0),
              child: Image.asset("res/drawable/ic_close.png"),
            )),
      SizedBox(
        height: 15,
      ),
      Container(
        height: 10,
        color: HexColor("#F2F2F2"),
      ),
    ],
  );
}

/*
Widget stakeInfoView(List<String> infoTitleList, List<String> infoContentList, bool isShowAll, Function showAllInfo) {
  return Column(
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  isShowAll ? infoTitleList.length : 3,
                      (index) => Container(
                    height: 38,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      infoTitleList[index],
                      style: TextStyle(fontSize: 14, color: HexColor("#92979A")),
                    ),
                  )).toList(),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  isShowAll ? infoContentList.length : 3,
                      (index) => Container(
                    height: 38,
                    alignment: Alignment.centerLeft,
                    child:
                    Text(infoContentList[index], style: TextStyle(fontSize: 14, color: HexColor("#333333"))),
                  )).toList(),
            ),
          )
        ],
      ),
      if (!isShowAll)
        InkWell(
            onTap: () {
              showAllInfo();
            },
            child: Image.asset("res/drawable/ic_close.png")),
      SizedBox(
        height: 15,
      ),
      Container(
        height: 10,
        color: HexColor("#F2F2F2"),
      ),
    ],
  );
}*/
