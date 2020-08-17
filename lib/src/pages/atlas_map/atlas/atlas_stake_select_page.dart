import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class AtlasStakeSelectPage extends StatefulWidget {
  AtlasStakeSelectPage();

  @override
  State<StatefulWidget> createState() {
    return _AtlasStakeSelectPageState();
  }
}

class _AtlasStakeSelectPageState extends State<AtlasStakeSelectPage> {
  var infoTitleList = ["总抵押", "签名率", "最近回报率"];
  var infoContentList = ["12930903", "98%", "11.23%"];

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
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Container(height: 60, child: Text("header")),
            stakeInfoView(),
            Center(
              child: Image.asset("res/drawable/ic_close.png"),
            ),
            SizedBox(height: 15,),
            Container(
              height: 10,
              color: HexColor("#F2F2F2"),
            ),
            Text("选择需要抵押的Map3节点"),
            Container(),
            Container(
              height: 10,
              color: HexColor("#F2F2F2"),
            ),
            Text("")
          ],
        )));
  }

  Widget stakeInfoView() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
                infoTitleList.length,
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
                infoContentList.length,
                (index) => Container(
                      height: 38,
                      alignment: Alignment.centerLeft,
                      child: Text(infoContentList[index], style: TextStyle(fontSize: 14, color: HexColor("#333333"))),
                    )).toList(),
          ),
        )
      ],
    );
  }
}
