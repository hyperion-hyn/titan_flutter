import 'package:flutter/material.dart';
import 'package:titan/src/business/map3/map3_node_introduction.dart';
import 'package:titan/src/business/wallet/wallet_page.dart';

class WalletContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletContentState();
  }
}

class _WalletContentState extends State<WalletContentWidget> {
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
                  Spacer(flex:1,),
                  Expanded(
                    flex: 3,
                    child: TabBar(
                      labelColor: Colors.black,
                      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 16),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 5,
                      unselectedLabelColor: Colors.grey[400],
                      tabs: [
                        Tab(
                          text: "钱包",
                        ),
                        Tab(
                          text: "map3节点",
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
        body: TabBarView(children: [WalletPage(), Map3NodeIntroductionPage()]),
      ),
    );
  }
}
