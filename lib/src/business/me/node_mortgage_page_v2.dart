import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/me/mortgage_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';

import 'model/mortgage_info_v2.dart';
import 'mortgage_snap_up_page.dart';

class NodeMortgagePageV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeMortgagePageV2();
  }
}

class _NodeMortgagePageV2 extends State<NodeMortgagePageV2> {
  UserService _userService = UserService();

  List<MortgageInfoV2> _mortgageList = [MortgageInfoV2(0, "", "", "", 0, "", 0, 0, 0)];

//  MortgageInfoV2 _selectedMortgageInfo = MortgageInfoV2(0, "", "", "", 0, "", 0, 0, 0);

  int selectedIndex = 0;

  NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.#####");

  @override
  void initState() {
    super.initState();
    _getContractList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
//          backgroundColor: Colors.white,
          title: Text(
            "节点抵押",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Material(
                  child: Container(
                    color: Color(0xFFFFF8EA),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            "节点抵押，随进随出，不限时间。",
                            style: TextStyle(color: Color(0xFFCE9D40)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: CarouselSlider(
                      onPageChanged: _onPageChanged,
                      height: 250.0,
                      enlargeCenterPage: true,
                      items: _mortgageList.map((_mortgageInfoTemp) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        FadeInImage.assetNetwork(
                                          image: _mortgageInfoTemp.icon,
                                          placeholder: 'res/drawable/img_placeholder.jpg',
//                                          width: 170,
                                          height: 130,
                                          fit: BoxFit.cover,
                                        )

                                      ],
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                    ),
                                    Spacer(),
                                    Row(
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Text(
                                              _mortgageInfoTemp.name,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  DOUBLE_NUMBER_FORMAT.format(_mortgageInfoTemp.amount),
                                                  style: TextStyle(
                                                      color: Color(0xFFf6927f),
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                Text("  USDT")
                                              ],
                                            )
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          children: <Widget>[
                                            Text(
                                              "${_mortgageList[selectedIndex].incomeCycle}天收益(%)",
                                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  _mortgageList[selectedIndex].incomeRate,
                                                  style: TextStyle(
                                                      color: Color(0xFFf6927f),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.normal),
                                                ),
                                                Text("")
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: EdgeInsets.only(left: 32, right: 32, bottom: 16, top: 16),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "节点介绍",
                              style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _mortgageList[selectedIndex].description,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MortgagePage(
                                                _mortgageList[selectedIndex],
                                              )));
                                },
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric( vertical: 8),
                                    child: Text(
                                      "购买",
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                color: Color(0xFFBF3330),
                                onPressed: _mortgageList[selectedIndex].snapUpStocks == 0 ? null : snapUpOnTap,
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0, top: 8, bottom: 8, right: 0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "抢购",
                                          style:
                                              TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "  剩余 ${_mortgageList[selectedIndex].snapUpStocks}",
                                          style:
                                              TextStyle(color: Color(0xFFFFC500), fontSize: 14, fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Future _getContractList() async {
    _mortgageList = await _userService.getMortgageListV2();
    if (mounted) {
      setState(() {});
    }
  }

  Future _onPageChanged(int index) {
    selectedIndex = index;
    setState(() {});
  }

  void snapUpOnTap() async {
    //获取最新的合约记录及库存
    await _getContractList();

    var selectedContract = _mortgageList[selectedIndex];
    if (selectedContract.snapUpStocks <= 0) {
      Fluttertoast.showToast(msg: "节点已抢购完");
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => MortgageSnapUpPage(_mortgageList[selectedIndex])));
  }
}
