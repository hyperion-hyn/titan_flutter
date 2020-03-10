import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/updater/updater_component.dart';
import 'package:titan/src/pages/discover/bloc/bloc.dart';
import 'package:titan/src/pages/discover/discover_page.dart';
import 'package:titan/src/pages/home/bloc/bloc.dart';

import '../../../env.dart';
import '../home/home_page.dart';
import '../wallet/wallet_tabs_page.dart';
import '../news/news_page.dart';
import '../mine/my_page.dart';
import 'drawer_component.dart';

class AppTabBarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppTabBarPageState();
  }
}

class AppTabBarPageState extends State<AppTabBarPage> {
  final GlobalKey _bottomBarKey = GlobalKey(debugLabel: 'bottomBarKey');

  var _currentTabIndex = 0;

  var _isHaveNewAnnouncement = false;

  @override
  Widget build(BuildContext context) {
    bool isDebug = env.buildType == BuildType.DEV;

    return UpdaterComponent(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        drawer: isDebug ? DrawerComponent() : null,
        bottomNavigationBar: BottomNavigationBar(
          key: _bottomBarKey,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.black38,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          currentIndex: _currentTabIndex,
          items: [
            BottomNavigationBarItem(title: Text(S.of(context).home_page), icon: Icon(Icons.home)),
            BottomNavigationBarItem(title: Text(S.of(context).wallet), icon: Icon(Icons.account_balance_wallet)),
            BottomNavigationBarItem(title: Text(S.of(context).discover), icon: Icon(Icons.explore)),
            BottomNavigationBarItem(
                title: Text(S.of(context).information),
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.description),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                            color: HexColor("#DA3B2A"),
                            shape: BoxShape.circle,
                            border: Border.all(color: HexColor("#DA3B2A"))),
                      ),
                    ),
                  ],
                )),
            BottomNavigationBarItem(title: Text(S.of(context).my_page), icon: Icon(Icons.person)),
          ],
        ),
        body: _getTabView(_currentTabIndex),
      ),
    );
  }

  Widget _getTabView(int index) {
    return IndexedStack(
      index: index,
      children: <Widget>[
        BlocProvider(create: (ctx) => HomeBloc(ctx), child: HomePage()),
        WalletTabsPage(),
        BlocProvider(create: (ctx) => DiscoverBloc(ctx), child: DiscoverPage()),
        NewsPage(),
        MyPage(),
      ],
    );

//    switch (index) {
//      case 1:
//        return WalletTabsPage();
//      case 2:
//        return DiscoverPage();
//      case 3:
//        return NewsPage();
//      case 4:
//        return MyPage();
//    }
//    return HomePage();
  }
}
