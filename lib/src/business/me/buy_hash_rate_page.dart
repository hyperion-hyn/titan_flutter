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

  List<ContractInfo> contractList = [];

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
//        backgroundColor: Colors.white,
        title: Text(
          "购买算力合约",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return _buildItem(contractList[index]);
          },
          itemCount: contractList.length,
        ),
      ),
    );
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
//                  Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => PurchasePage(
//                                contractInfo: contractInfo,
//                              )));
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
}
