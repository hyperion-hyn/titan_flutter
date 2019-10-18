import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/me/mortgage_page.dart';
import 'package:titan/src/business/me/purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';

import 'model/contract_info_v2.dart';
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

  List<MortgageInfoV2> contractList = [MortgageInfoV2(0, "", "", "", 0, "", 0, 0)];

  MortgageInfoV2 _selectedMortgageInfo = MortgageInfoV2(0, "", "", "", 0, "", 0, 0);

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
                      items: contractList.map((_contractInfoTemp) {
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
                                        Image.memory(
                                          Base64Decoder().convert(
                                              (_contractInfoTemp.icon.replaceAll("data:image/png;base64,", ""))),
                                          height: 130,
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
                                               _contractInfoTemp.name,
                                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                             ),
                                             Row(
                                               children: <Widget>[
                                                 Text(
                                                   DOUBLE_NUMBER_FORMAT.format(_contractInfoTemp.amount),
                                                   style: TextStyle(
                                                       color: Color(0xFFf6927f), fontSize: 18, fontWeight: FontWeight.bold),
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
                                               "30天收益(USDT)",
                                               style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                             ),
                                             Row(
                                               children: <Widget>[
                                                 Text(
                                                   _selectedMortgageInfo.incomeRate,
                                                   style: TextStyle(
                                                       color: Color(0xFFf6927f), fontSize: 14, fontWeight: FontWeight.normal),
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
                              "合约介绍",
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _selectedMortgageInfo.description,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MortgagePage(
                                              _selectedMortgageInfo,
                                            )));
                              },
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
                                  child: Text(
                                    "购买",
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              color: Colors.red,
                              onPressed: _selectedMortgageInfo.snapUpStocks == 0 ? null : snapUpOnTap,
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 30,top: 8,bottom: 8,right: 0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        "抢购",
                                        style:
                                            TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "  剩余 ${_selectedMortgageInfo.snapUpStocks}",
                                        style:
                                            TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
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
    contractList = await _userService.getMortgageListV2();
    _selectedMortgageInfo = contractList[0];

    if (mounted) {
      setState(() {});
    }
  }

  Future _onPageChanged(int index) {
    _selectedMortgageInfo = contractList[index];
    setState(() {});
  }

  void snapUpOnTap() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MortgageSnapUpPage(_selectedMortgageInfo)));
  }
}
