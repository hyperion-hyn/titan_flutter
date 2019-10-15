import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/contract_info.dart';
import 'package:titan/src/business/me/purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

class BuyHashRatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BuyHashRateState();
  }
}

class _BuyHashRateState extends State<BuyHashRatePage> {
  UserService _userService = UserService();

  List<ContractInfo> contractList = [ContractInfo(0, 0.0, 0, 0, 0, 0)];

  ContractInfo _selectedContractInfo = ContractInfo(0, 0.0, 0, 0, 0, 0);

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
          backgroundColor: Colors.white,
          title: Text(
            "购买算力合约",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
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
                  flex: 1,
                  child: Container(
                    child: CarouselSlider(
                      onPageChanged: _onPageChanged,
                      height: 300.0,
                      enlargeCenterPage: true,
                      items: contractList.map((_contractInfoTemp) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Text(
                                  'text ${_contractInfoTemp.power} 算力.',
                                  style: TextStyle(fontSize: 16.0),
                                ));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(36),
                    child: Column(
                      children: <Widget>[
                        Spacer(),
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

  Widget _buildItem(ContractInfo contractInfo) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.white,
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      ExtendsIconFont.rocket,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    "${contractInfo.power}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '算力',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "每人限购${contractInfo.limit}份",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        "",
                        style: TextStyle(color: Color(0xFF6D6D6D)),
                      )
                    ],
                  )
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.black12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${Const.DOUBLE_NUMBER_FORMAT.format(contractInfo.amount)}",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      Text(
                        "购买所需(USDT)",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${Const.DOUBLE_NUMBER_FORMAT.format(contractInfo.monthInc + contractInfo.amount)}",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      Text(
                        "45天收益(USDT)",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PurchasePage(
                                contractInfo: contractInfo,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
                  child: Text(
                    "购买",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _getContractList() async {
    contractList = await _userService.getContractList();

    setState(() {});
  }

  Future _onPageChanged(int index) {
    _selectedContractInfo = contractList[index];
  }
}
