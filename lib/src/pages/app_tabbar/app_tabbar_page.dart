import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/updater/updater_component.dart';

import '../../../env.dart';
import '../home/home_page.dart';
import '../wallet/wallet_page.dart';
import '../discover/discover_page.dart';
import '../news/news_page.dart';
import '../mine/mine_page.dart';
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
            BottomNavigationBarItem(title: Text(S.of(context).information), icon: Icon(Icons.description)),
            BottomNavigationBarItem(title: Text(S.of(context).my_page), icon: Icon(Icons.person)),
          ],
        ),
        body: Stack(
          children: <Widget>[
            //tab views
            _getTabView(_currentTabIndex),
          ],
        ),
      ),
    );
  }

  Widget _getTabView(int index) {
    switch (index) {
      case 1:
        return WalletPage();
      case 2:
        return DiscoverPage();
      case 3:
        return NewsPage();
      case 4:
        return MinePage();
    }
    return HomePage();
  }
}
