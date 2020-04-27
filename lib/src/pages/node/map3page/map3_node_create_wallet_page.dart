import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/routes.dart';

class Map3NodeCreateWalletPage extends StatelessWidget {
  
  static const String CREATE_WALLET_PAGE_TYPE_CREATE = "create";
  static const String CREATE_WALLET_PAGE_TYPE_JOIN = "join";
  final String type;
  Map3NodeCreateWalletPage(this.type);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(S.of(context).wallet_account)),
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
                    type == CREATE_WALLET_PAGE_TYPE_CREATE?S.of(context).create_map_node_must_have_block_account:S.of(context).join_map_node_must_have_block_account,
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
