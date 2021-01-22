import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
import 'package:titan/src/pages/market/exchange/exchange_page.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_page_v2.dart';
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffEDC313), Color(0xffF7D33D)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: DefaultColors.color333,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: DefaultColors.color333,
                  indicatorWeight: 2,
                  indicatorPadding: EdgeInsets.only(bottom: 2),
                  unselectedLabelStyle: TextStyle(
                    color: DefaultColors.color333,
                  ),
                  tabs: [
                    Tab(
                      child: Text(
                        S.of(context).wallet,
                        style: TextStyle(),
                      ),
                    ),
                    Tab(
                      child: Text(
                        S.of(context).exchange,
                        style: TextStyle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            WalletPageV2(),
            ExchangePage(),
          ],
        ),
      ),
    );
  }
}
