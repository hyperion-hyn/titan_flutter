import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';

import 'map3_node_contract_detail_page.dart';
import 'map3_node_create_contract_page.dart';

class Map3NodeBroadcaseSuccessPage extends StatelessWidget {
  final String pageType;
  final ContractNodeItem contractNodeItem;
  Map3NodeBroadcaseSuccessPage(this.pageType, {this.contractNodeItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _pop(context);
                  },
                );
              },
            ),
            centerTitle: true,
            title: Text(S.of(context).broadcase_success)),
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
                    height: 76,
                    width: 124,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.asset(
                        "res/drawable/check_outline.png",
                        fit: BoxFit.contain,
                        width: 72,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 250,
                  child: Text(
                    S.of(context).map_node_broadcase_success_description(pageType == Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_CREATE ? S.of(context).create : S.of(context).join),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 70),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /*Container(
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
                      ),*/
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                        child: Container(
                          constraints: BoxConstraints.expand(height: 48),
                          child: FlatButton(
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(36)),
                            onPressed: () {

                              _pop(context);

                              //Routes.popUntilCachedEntryRouteName(context);

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
                                  S.of(context).finish,
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

  void _pop(BuildContext context) {

    switch (this.pageType) {
      case Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_CREATE:
        print("[pop] -----> _pop, contractNodeItem:${this.contractNodeItem.toJson()}");

        Routes.popUntilCachedEntryRouteName(context, this.contractNodeItem);
        break;

      default:
        Routes.popUntilCachedEntryRouteName(context, true);
        break;
    }

  }

}
