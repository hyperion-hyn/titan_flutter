import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/market/exchange/exchange_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_introduction.dart';
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/style/titan_sytle.dart';

import 'wallet_page/wallet_page.dart';

class WalletTabsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletTabsPageState();
  }
}

class _WalletTabsPageState extends State<WalletTabsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(
      initialIndex: 0,
      vsync: this,
      length: 2,
    );
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
            color: Colors.white,
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: HexColor('#FF228BA1'),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: HexColor('#FF228BA1'),
                      indicatorWeight: 3,
                      indicatorPadding: EdgeInsets.only(bottom: 2),
                      unselectedLabelColor: HexColor("#FF333333"),
                      tabs: [
                        Tab(
                          child: Text(
                            S.of(context).wallet,
                            style: TextStyle(),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '交易',
                            style: TextStyle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16.0,
                    top: 16.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebViewContainer(
                                      initUrl: Const.POI_POLICY,
                                      title: S.of(context).poi_upload_protocol,
                                    )));
                      },
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'res/drawable/ic_wallet_qualification.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            '资质',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
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
            ExchangePage(),
          ],
        ),
      ),
    );
  }
}
