import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

import 'wallert_create_new_account_page.dart';
import 'wallert_import_account_page.dart';

class EmptyWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Image.asset(
            "res/drawable/safe_lock.png",
            width: 72,
          ),
        ),
        Text(
          "私密和安全",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "账户私钥永远不会离开你的设备",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey[400]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(36)),
                onPressed: () {
//                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                  Fluttertoast.showToast(msg: "即将开放");
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                    child: Text(
                      "创建钱包",
                      style:
                          TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(36)),
                  onPressed: () {
//                    Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                    Fluttertoast.showToast(msg: "即将开放");
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        "导入钱包",
                        style:
                            TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.all(16),
          color: HexColor("#F5F5F5"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "HYN行情",
                    style: TextStyle(color: HexColor("#9B9B9B"), fontSize: 14),
                  ),
                  Spacer(),
                  Text(
                    "查看全部",
                    style: TextStyle(color: HexColor("#9B9B9B"), fontSize: 14),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: HexColor("#9B9B9B"),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "0.28美元",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "HYN指数",
                          style: TextStyle(color: HexColor("#6D6D6D"), fontSize: 14),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "12",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text("上线交易所", style: TextStyle(color: HexColor("#6D6D6D"), fontSize: 14)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
