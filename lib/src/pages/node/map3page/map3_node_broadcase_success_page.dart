import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';

import 'map3_node_create_contract_page.dart';

class Map3NodeBroadcaseSuccessPage extends StatelessWidget {
  String pageType;

  Map3NodeBroadcaseSuccessPage(this.pageType);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Routes.popUntilCreateOrImportWalletEntryRoute(context);
//                    Navigator.of(context).pop();
                  },
                );
              },
            ),
            centerTitle: true,
            title: Text("广播成功")),
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
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      "res/drawable/ic_map3_node_item.png",
                      fit: BoxFit.cover,
                      width: 72,
                    ),
                  ),
                ),
                Container(
                  width: 250,
                  child: Text(
                    "已在区块链上网络广播 ${pageType == Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_CREATE ? "创建" : "参加"}"
                        + " Map3节点抵押合约的消息，区块链网络需要5-30分钟开采验证。",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 70),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        constraints: BoxConstraints.expand(height: 48),
                        child: FlatButton(
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(36)),
                          onPressed: () {
                            Share.text(S.of(context).share, "http://baidu.com",
                                'text/plain');
//                            Application.router.navigateTo(
//                                context,
//                                Routes.wallet_create +
//                                    '?entryRouteName=${Uri.encodeComponent(Routes.map3node_product_list)}');
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 12.0),
                              child: Text(
                                "分享",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                        child: Container(
                          constraints: BoxConstraints.expand(height: 48),
                          child: FlatButton(
                            color: DefaultColors.color26ac29,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: DefaultColors.color26ac29),
                                borderRadius: BorderRadius.circular(36)),
                            onPressed: () {
//                              Application.router.navigateTo(
//                                  context,
//                                  Routes.wallet_import +
//                                      '?entryRouteName=${Uri.encodeComponent(Routes.map3node_product_list)}');
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 12.0),
                                child: Text(
                                  "查看合约详情",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
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
