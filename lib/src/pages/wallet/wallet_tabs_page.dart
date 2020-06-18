import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/extends_icon_font.dart';
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

class _WalletTabsPageState extends State<WalletTabsPage>
    with SingleTickerProviderStateMixin {
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
            color: Colors.white,
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 16.0,
                      ),
                      Expanded(
                        flex: 3,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 2,
                          indicatorPadding: EdgeInsets.only(bottom: 2),
                          unselectedLabelColor: Colors.black,
                          tabs: [
                            Tab(
                              child: Text(
                                S.of(context).wallet,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '交易',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(
                        flex: 3,
                      )
                    ],
                  ),
                  Positioned(
                    top: 16.0,
                    right: 16.0,
                    child: InkWell(
                      onTap: () async {
                        String scanStr = await BarcodeScanner.scan();
                      },
                      child: Icon(
                        ExtendsIconFont.qrcode_scan,
                        color: Colors.black,
                        size: 20,
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
            Container(),
          ],
//          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
