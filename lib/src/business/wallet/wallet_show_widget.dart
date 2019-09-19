import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallet_show_account_widget.dart';

import 'wallert_create_new_account_page.dart';
import 'wallert_import_account_page.dart';

class ShowWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ShowWalletState();
  }
}

class _ShowWalletState extends State<ShowWallet> {
  List<WalletAccount> walletAccounts = [
    WalletAccount(
        name: "Ethereun",
        shortName: "ETH",
        count: 123.02,
        price: 180.92,
        priceUnit: "USD",
        unit: "ETH",
        amount: 22256.77),
    WalletAccount(
        name: "Hyperion",
        shortName: "HYN",
        count: 123.02,
        price: 180.92,
        priceUnit: "USD",
        unit: "HYN",
        amount: 22256.77)
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Text(
                            "US \$100",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("钱包1"),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 8,
                  child: Text(
                    "管理",
                    style: TextStyle(color: HexColor("#FF3F51B5")),
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 2,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(onTap:(){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowAccountPage()));
              },child: _buildAccountItem(context, walletAccounts[index]));
            },
            itemCount: walletAccounts.length,
          )
        ]);
  }

  Widget _buildAccountItem(BuildContext context, WalletAccount account) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              shape: BoxShape.circle,
            ),
            child: Text("HYN"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Ethereum",
                  style: TextStyle(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "USD180.92",
                    style: TextStyle(fontSize: 11, color: HexColor("#FF848181")),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Ethereum",
                  style: TextStyle(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "USD180.92",
                    style: TextStyle(fontSize: 11, color: HexColor("#FF848181")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletAccount {
  String name;
  String shortName;
  double count;
  double price;
  String priceUnit;
  String unit;
  double amount;

  WalletAccount({this.name, this.shortName, this.count, this.price, this.priceUnit, this.unit, this.amount});
}
