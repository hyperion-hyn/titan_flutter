import 'package:flutter/material.dart';

import 'wallert_create_new_account_page.dart';
import 'wallert_import_account_page.dart';

class EmptyWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.account_balance_wallet,
            color: Colors.black,
            size: 70,
          ),
          Container(
              width: 220,
              child: Text(
                "HYN钱包是基于以太坊ERC20的离线钱包，使用钱包可以支付地图购买，投资节点等",
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 3,
              )),
          Container(
            height: 200,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 16.0),
                    child: Text(
                      "创建钱包",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                color: Colors.blue,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "导入钱包",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
