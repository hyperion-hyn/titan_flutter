import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:titan/src/business/home/bloc/bloc.dart' as home;
import 'package:titan/src/business/home/discover_content.dart';
import 'package:titan/src/business/home/home_panel.dart';
import 'package:titan/src/business/home/information_content.dart';
import 'package:titan/src/business/home/my_content.dart';
import 'package:titan/src/business/home/wallet_content.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/scaffold_map.dart';
import 'package:titan/src/business/updater/updater.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/utils/encryption.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';
import 'package:uni_links/uni_links.dart';

import '../../../env.dart';
import '../../global.dart';
import 'bloc/bloc.dart';
import 'bottom_fabs_widget.dart';
import 'drawer/drawer_scenes.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey _bottomBarKey = GlobalKey(debugLabel: 'bottomBarKey');
  final GlobalKey fabsContainerKey = GlobalKey(debugLabel: 'fabsContainerKey');

  DraggableBottomSheetController _poiBottomSheetController = DraggableBottomSheetController();
  DraggableBottomSheetController _homeBottomSheetController = DraggableBottomSheetController(collapsedHeight: 110);
  DraggableBottomSheetController _activeBottomSheetController;
  ScrollController _homeBottomSheetChildrenScrollController = ScrollController();

  StreamSubscription _appLinkSubscription;

  var _currentIndex = 0;

  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 2000), vsync: this);

    initUniLinks();
    print("initState");

    SchedulerBinding.instance.addPostFrameCallback((_) {
      bottomBarHeight = UtilUi.getRenderObjectHeight(_bottomBarKey);
    });

    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      eventBus.fire(ToMyLocationEvent());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context).isCurrent) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    }
    print("didChangeDependencies");
  }

  @override
  Widget build(BuildContext context) {
    bool isDebug = env.buildType == BuildType.DEV;
    return MultiBlocListener(
      listeners: [
        BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
          listener: (context, state) {
            if (state is InitialScaffoldMapState) {
              BlocProvider.of<home.HomeBloc>(context).add(home.HomeInitEvent());
            } else {
              BlocProvider.of<home.HomeBloc>(context).add(home.MapOperatingEvent());
            }
          },
        ),
      ],
      child: Updater(
          child: Scaffold(
              resizeToAvoidBottomPadding: false,
              drawer: isDebug ? DrawerScenes() : null,
//          endDrawer: PurchasedMapDrawerScenes(),
              bottomNavigationBar: BlocBuilder<home.HomeBloc, home.HomeState>(
                builder: (context, state) {
                  double height;
                  if (state is home.MapOperatingState) {
                    height = 0;
                  }
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height: height,
//                  curve: Curves.fastOutSlowIn,
                    child: BottomNavigationBar(
                        key: _bottomBarKey,
                        selectedItemColor: Theme.of(context).primaryColor,
                        unselectedItemColor: Colors.black38,
                        showUnselectedLabels: true,
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        type: BottomNavigationBarType.fixed,
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        currentIndex: _currentIndex,
                        items: [
                          BottomNavigationBarItem(title: Text("首页"), icon: Icon(Icons.home)),
                          BottomNavigationBarItem(title: Text("钱包"), icon: Icon(Icons.account_balance_wallet)),
                          BottomNavigationBarItem(title: Text("发现"), icon: Icon(Icons.explore)),
                          BottomNavigationBarItem(title: Text("资讯"), icon: Icon(Icons.description)),
                          BottomNavigationBarItem(title: Text("我的"), icon: Icon(Icons.person)),
                        ]),
                  );
                },
              ),
              body: BlocBuilder<home.HomeBloc, home.HomeState>(
                bloc: BlocProvider.of<home.HomeBloc>(context),
                builder: (context, state) {
                  if (state is InitialHomeState) {
                    if (_activeBottomSheetController != null) {
                      _activeBottomSheetController.removeListener(onBottomSheetChange);
                    }

                    var state = _homeBottomSheetController.getSheetState();
                    if (state == DraggableBottomSheetState.HIDDEN || state == null) {
                      _homeBottomSheetController.setSheetState(DraggableBottomSheetState.COLLAPSED);
                    }
                    _activeBottomSheetController = _homeBottomSheetController;
                  } else if (state is home.MapOperatingState) {
                    _homeBottomSheetController.setSheetState(DraggableBottomSheetState.HIDDEN);
                    _activeBottomSheetController = _poiBottomSheetController;
                  }
                  _activeBottomSheetController.addListener(onBottomSheetChange);
                  return Stack(
                    children: <Widget>[
                      //地图
                      ScaffoldMap(
                        poiBottomSheetController: _poiBottomSheetController,
                      ),

                      //位置按钮
                      BottomFabsWidget(
                        key: fabsContainerKey,
                        showBurnBtn: state is InitialHomeState,
                      ),

                      //首页bottom sheet
                      DraggableBottomSheet(
                        draggable: true,
                        controller: _homeBottomSheetController,
                        childScrollController: _homeBottomSheetChildrenScrollController,
                        topPadding: (MediaQuery.of(context).padding.top),
                        topRadius: 16,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: HomePanel(
                            scrollController: _homeBottomSheetChildrenScrollController,
                          ),
                        ),
                      ),
                      //tabs
                      _getContent(_currentIndex),
                    ],
                  );
                },
              ))),
    );
  }

  void onBottomSheetChange() {
    var bottom = _activeBottomSheetController?.bottom;
    if (bottom != null) {
      var state = fabsContainerKey.currentState as BottomFasScenesState;
      state.updateBottomPadding(bottom, _activeBottomSheetController.anchorHeight);
    }
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    animationController.dispose();
    super.dispose();
  }

  Widget _getContent(int index) {
    switch (index) {
      case 0:
        return Container();
      case 1:
        return WalletContentWidget();
      case 2:
        return DiscoverContentWidget();
      case 3:
        return InformationContentWidget();
      case 4:
        return MyContentWidget();
    }
    return Container();
  }

  Future<Null> initUniLinks() async {
    try {
      String initialLink = await getInitialLink();
      print("initialLink listen url $initialLink");

      try {
        if (initialLink == null || initialLink.isEmpty) {
          return;
        }
        IPoi poi = await ciphertextToPoi(Injector.of(context).repository, initialLink.toString());
        BlocProvider.of<home.HomeBloc>(context)
            .add(home.SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
      } catch (err) {
        logger.e(err);
      }
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }

    // Attach a listener to the stream
    _appLinkSubscription = getLinksStream().listen((String link) async {
      print("listenlink listen url $link");

      try {
        IPoi poi = await ciphertextToPoi(Injector.of(context).repository, link.toString());
        BlocProvider.of<home.HomeBloc>(context)
            .add(home.SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
      } catch (err) {
        logger.e(err);
      }
    }, onError: (err) {
      print(err);
    });
  }
}
