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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("购买算力合约"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _buildItem(contractList[index]);
        },
        itemCount: contractList.length,
      ),
    );
  }

  Widget _buildItem(ContractInfo contractInfo) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Material(
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(ExtendsIconFont.engine),
                  Text(
                    "${contractInfo.power}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    'POH算力',
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                  Spacer(),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PurchasePage(contractInfo: contractInfo,)));
                    },
                    child: Text(
                      "购买",
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
                      "购买所需",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ),
                  Text(
                    "${Const.DOUBLE_NUMBER_FORMAT.format(contractInfo.amount)} U",
                    style: TextStyle(color: Colors.black87),
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
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Text(
                    "${Const.DOUBLE_NUMBER_FORMAT.format(contractInfo.monthInc)} U",
                    style: TextStyle(color: Colors.black87),
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
                      "购买上限",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Text(
                    "每人最多${contractInfo.limit}份",
                    style: TextStyle(color: Colors.black87),
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
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Text(
                    "每日返还",
                    style: TextStyle(color: Colors.black87),
                  )
                ],
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
