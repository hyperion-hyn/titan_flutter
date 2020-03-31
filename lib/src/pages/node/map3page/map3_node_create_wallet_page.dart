import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/routes.dart';

class Map3NodeCreateWalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text("钱包账户")),
        body: Container(
          color: Colors.white,
          child: Center(
//          color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Container(
                    width: 73,
                    height: 86,
                    child: Image.asset(
                      "res/drawable/safe_lock.png",
                      width: 72,
                    ),
                  ),
                ),
                Container(
                  width: 250,
                  child: Text(
                    "创建Map3抵押节点前，你必须先拥有一个区块链钱包账户。",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 70),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            side:
                                BorderSide(color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(36)),
                        onPressed: () {
                          Application.router.navigateTo(
                              context,
                              Routes.wallet_create +
                                  '?entryRouteName=${Uri.encodeComponent(Routes.map3node_product_list)}');
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 12.0),
                            child: Text(
                              S.of(context).create_wallet,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(36)),
                          onPressed: () {
                            Application.router.navigateTo(
                                context,
                                Routes.wallet_import +
                                    '?entryRouteName=${Uri.encodeComponent(Routes.map3node_product_list)}');
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 12.0),
                              child: Text(
                                S.of(context).import_wallet,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
