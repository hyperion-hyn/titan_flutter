import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/node/map3page/map3_node_introduction.dart';
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';
import 'package:titan/src/style/titan_sytle.dart';

import 'wallet_page/wallet_page.dart';

class WalletTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletTabsPageState();
  }
}

class _WalletTabsPageState extends State<WalletTabsPage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(initialIndex: 0, vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppTabBarBloc, AppTabBarState>(
      listener: (context, state) {
        if (state is ChangeTabBarItemState) {
          if (state.index == 1) {
            this.setState(() {
              _tabController.index = 0;
            });
          }
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      indicatorSize: TabBarIndicatorSize.label,
//                      labelPadding: EdgeInsets.only(left: 10, right: 20),
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorPadding: EdgeInsets.only(bottom: 2),
//                      indicatorColor: HexColor("#00000000"),
                      unselectedLabelColor: HexColor("#aaffffff"),
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
                  Expanded(flex: 2, child: Text(""))
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            WalletPage(),
            // todo: test_jison_0424
            Map3NodePage(),
//            Map3NodeIntroductionPage(),
//            Center(
//              child: Text('this is wallet page'),
//            ),
//            Center(
//              child: Text('this is map3 node page'),
//            )
          ],
//          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
