import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/node/map3page/map3_node_introduction.dart';
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';

import 'wallet_page/wallet_page.dart';

class WalletTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletTabsPageState();
  }
}

class _WalletTabsPageState extends State<WalletTabsPage> with SingleTickerProviderStateMixin{
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(
      initialIndex: 0,
        vsync: this,
        length: 2
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppTabBarBloc, AppTabBarState>(
      listener: (context, state) {
        if (state is ChangeTabBarItemState) {
          if(state.index == 1){
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
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: TabBar(
                      controller: _tabController,
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
          controller: _tabController,
          children: [
            WalletPage(),
            Map3NodePage(),
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
