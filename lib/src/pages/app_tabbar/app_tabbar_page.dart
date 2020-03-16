import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/scaffold_map/scaffold_map.dart';
import 'package:titan/src/components/updater/updater_component.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/app_tabbar/bloc/app_tabbar_bloc.dart';
import 'package:titan/src/pages/app_tabbar/bloc/bloc.dart';
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

class AppTabBarPageState extends State<AppTabBarPage> with SingleTickerProviderStateMixin {
  final GlobalKey _bottomBarKey = GlobalKey(debugLabel: 'bottomBarKey');

  int _currentTabIndex = 0;

  bool _isHaveNewAnnouncement = false;
  bool _isHideBottomNavigationBar = false;
  AnimationController _bottomBarPositionAnimationController;

  @override
  void initState() {
    super.initState();

    _bottomBarPositionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 0.0,
      vsync: this,
    );

    //set the status bar color
    FlutterStatusbarcolor.setStatusBarColor(Colors.black12);
  }

  @override
  Widget build(BuildContext context) {
    bool isDebug = env.buildType == BuildType.DEV;
    return UpdaterComponent(
      child: MultiBlocListener(
        listeners: [
          BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
            listener: (context, state) {
              if (state is DefaultScaffoldMapState) {
                _bottomBarPositionAnimationController.animateBack(0, curve: Curves.easeInQuart);
              } else {
                _bottomBarPositionAnimationController.animateTo(1, curve: Curves.easeOutQuint);
              }
            },
          ),
        ],
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          drawer: isDebug ? DrawerComponent() : null,
          body: Stack(
            children: <Widget>[
              //map at background
              ScaffoldMap(),
              _getTabView(_currentTabIndex),
              bottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomNavigationBar() {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      var additionalBottomPadding = MediaQuery.of(context).padding.bottom;
      var barHeight = additionalBottomPadding + kBottomNavigationBarHeight;
      var expandedRelative = RelativeRect.fromLTRB(0.0, constraints.biggest.height - barHeight, 0.0, 0.0);
      var hideRelative = RelativeRect.fromLTRB(0.0, constraints.biggest.height, 0.0, -barHeight);
      final Animation<RelativeRect> barAnimationRect = _bottomBarPositionAnimationController.drive(
        RelativeRectTween(
          begin: expandedRelative,
          end: hideRelative,
        ),
      );

      return Stack(
        children: <Widget>[
          PositionedTransition(
            rect: barAnimationRect,
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8.0,
                  ),
                ],
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  tabItem(Icons.home, S.of(context).home_page, 0),
                  tabItem(Icons.account_balance_wallet, S.of(context).wallet, 1),
                  tabItem(Icons.explore, S.of(context).discover, 2),
                  tabItem(Icons.description, S.of(context).information, 3),
                  tabItem(Icons.person, S.of(context).my_page, 4),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget tabItem(IconData iconData, String text, int index) {
    bool selected = index == this._currentTabIndex;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(80),
          onTap: () => {
            this.setState(() {
              this._currentTabIndex = index;
            })
          },
          child: Container(
            padding: EdgeInsets.only(top: 4, bottom: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  iconData,
                  color: selected ? Theme.of(context).primaryColor : Colors.black38,
                ),
                Text(
                  text,
                  style: TextStyle(fontSize: 12, color: selected ? Theme.of(context).primaryColor : Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTabView(int index) {
    var barHeight = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    return Padding(
      padding: EdgeInsets.only(bottom: barHeight),
      child: IndexedStack(
        index: index,
        children: <Widget>[
          BlocProvider(create: (ctx) => HomeBloc(ctx), child: HomePage()),
          WalletTabsPage(),
          BlocProvider(create: (ctx) => DiscoverBloc(ctx), child: DiscoverPage()),
          NewsPage(),
          MyPage(),
        ],
      ),
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

//  Widget home() {
//    return Container(
//      color: Colors.red,
//      child: Center(
//        child: RaisedButton(
//          onPressed: () {
//            _isShowBottomNavigationBar = !_isShowBottomNavigationBar;
//            if (_isShowBottomNavigationBar) {
//              //show
//              _bottomBarPositionAnimationController.animateBack(0, curve: Curves.easeInQuart);
//            } else {
//              //hide
//              _bottomBarPositionAnimationController.animateTo(1, curve: Curves.easeOutQuint);
//            }
////            setState(() {
////              _isShowBottomNavigationBar = !_isShowBottomNavigationBar;
////            });
//          },
//          child: Text('hhh'),
//        ),
//      ),
//    );
//  }
}
