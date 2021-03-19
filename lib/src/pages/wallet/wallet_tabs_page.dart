import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/setting/setting_component.dart';
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

    var isHiddenSwap =
        SettingInheritedModel.ofConfig(context)?.systemConfigEntity?.isHiddenSwap??false;
    print("[wallet] isHiddenSwap:$isHiddenSwap");

    if (!isHiddenSwap) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 18,),
          child: WalletPageV2(),
        ),
      );
    }
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 2,
                  indicatorPadding: EdgeInsets.only(
                    bottom: 2,
                    right: 6,
                    left: 6,
                  ),
                  unselectedLabelColor: HexColor("#FF333333"),
                  tabs: [
                    Tab(
                      child: Text(
                        S.of(context).wallet,
                        style: TextStyle(
                          // color: DefaultColors.color333,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        S.of(context).exchange,
                        style: TextStyle(
                          // color: DefaultColors.color333,
                        ),
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
