import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/me/purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';

import 'model/contract_info_v2.dart';

class BuyHashRatePageV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BuyHashRateStateV2();
  }
}

class _BuyHashRateStateV2 extends State<BuyHashRatePageV2> {
  UserService _userService = UserService();

  List<ContractInfoV2> contractList = [ContractInfoV2(0, "", "", "", 0, 0, 0, 0, 0, 0, 0)];

  ContractInfoV2 _selectedContractInfo = ContractInfoV2(0, "", "", "", 0, 0, 0, 0, 0, 0, 0);

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
            "购买算力合约",
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
                Expanded(
                  flex: 4,
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
                                        FadeInImage.assetNetwork(
                                          image: _contractInfoTemp.icon,
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
                                              _contractInfoTemp.name,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  DOUBLE_NUMBER_FORMAT.format(_contractInfoTemp.amount),
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
                                              "${_contractInfoTemp.timeCycle}天收益(USDT)",
                                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  DOUBLE_NUMBER_FORMAT.format(_contractInfoTemp.monthInc),
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
                  flex: 6,
                  child: Container(
                    margin: EdgeInsets.only(left: 32, right: 32, bottom: 16, top: 16),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "合约介绍",
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "每人限购${_selectedContractInfo.limit}份",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _selectedContractInfo.description,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PurchasePage(
                                          contractInfo: _selectedContractInfo,
                                        )));
                          },
                          child: Container(
                            constraints: BoxConstraints.expand(height: 48),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
                              child: Text(
                                "购买",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
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
    contractList = await _userService.getContractListV2();
    _selectedContractInfo = contractList[0];

    setState(() {});
  }

  Future _onPageChanged(int index) {
    _selectedContractInfo = contractList[index];
    setState(() {});
  }
}
