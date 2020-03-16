import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';

import 'wallet_page/wallet_page.dart';

class WalletTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletTabsPageState();
  }
}

class _WalletTabsPageState extends State<WalletTabsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: TabBar(
                      labelColor: Colors.black,
                      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 4,
                      unselectedLabelColor: Colors.grey[400],
                      tabs: [
                        Tab(
                          text: S.of(context).wallet,
                        ),
                        Tab(
                          text: S.of(context).map3_node_introduction,
                        ),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  )
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [

            WalletPage(),
//            Map3NodeIntroductionPage(),
//            Center(
//              child: Text('this is wallet page'),
//            ),
            Center(
              child: Text('this is map3 node page'),
            )
          ],
//          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
