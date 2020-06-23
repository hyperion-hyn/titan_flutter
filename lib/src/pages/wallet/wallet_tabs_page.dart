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
    _tabController = new TabController(initialIndex: 0, vsync: this, length: 1);
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          indicatorPadding: EdgeInsets.only(bottom: 2),
                          unselectedLabelColor: HexColor("#FF333333"),
                          tabs: [
                            Tab(
                              text: S.of(context).wallet,
                            ),
                            ///Tab(text: '交易'),
                          ],
                        ),
                      ),
                      //Expanded(flex: 2, child: Text(""))
                      Spacer(
                        flex: 2,
                      )
                    ],
                  ),
//                  Positioned(
//                    top: 16.0,
//                    right: 16.0,
//                    child: InkWell(
//                      onTap: () async {
//                        String scanStr = await BarcodeScanner.scan();
//                      },
//                      child: Icon(
//                        ExtendsIconFont.qrcode_scan,
//                        color: Colors.black,
//                        size: 20,
//                      ),
//                    ),
//                  )
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            WalletPage(),
          ],
        ),
      ),
    );
  }
}
