import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show PlatformException, SystemChrome, SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/business/home/bloc/bloc.dart' as home;
import 'package:titan/src/business/home/discover_content.dart';
import 'package:titan/src/business/home/home_panel.dart';
import 'package:titan/src/business/home/information_content.dart';
import 'package:titan/src/business/home/my_content.dart';
import 'package:titan/src/business/home/wallet_content.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/scaffold_map.dart';
import 'package:titan/src/business/updater/updater.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/utils/encryption.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/selecte_app_area_dialog.dart';
import 'package:uni_links/uni_links.dart';

import '../../widget/draggable_scrollable_sheet.dart' as myWidget;
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
  final GlobalKey panelKey = GlobalKey(debugLabel: 'panelKey');

//  DraggableBottomSheetController _poiBottomSheetController = DraggableBottomSheetController();

  StreamSubscription _appLinkSubscription;
  var selectedAppArea = AppArea.MAINLAND_CHINA_AREA.key;

  var _currentIndex = 0;

  AnimationController animationController;

  var isLoadAppArea = false;
  var isShowSetAppAreaDialog = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 2000), vsync: this);

    initUniLinks();

//    _loadAppArea();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      bottomBarHeight = UtilUi.getRenderObjectHeight(_bottomBarKey);
      if (isShowSetAppAreaDialog == false) {
        _loadAppArea();
      }
    });

    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      eventBus.fire(ToMyLocationEvent());
    });
  }

  void _showSetAreaAppDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SelecteAppAreaDialog(),
          );
        },
        barrierDismissible: false);
  }

  void _loadAppArea() async {
    isShowSetAppAreaDialog = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String appAreaKey = prefs.getString(PrefsKey.appArea);
    isLoadAppArea = true;
    if (appAreaKey == null) {
      _showSetAreaAppDialog();
    } else {
      appAreaChange(AppArea.APP_AREA_MAP[appAreaKey]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    if (ModalRoute.of(context).isCurrent) {
      _updateStatusBar();
    } else {
      //other route set status text to white color
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    }
  }

  void _updateStatusBar() {
    if ([0, 1, 3].indexOf(_currentIndex) > -1) {
      //status text black color
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    }
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
        BlocListener<home.HomeBloc, home.HomeState>(
          listener: (context, state) {
            //while listener trigger before build, the panelKey is not set, so call after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (state is InitialHomeState) {
                myWidget.DraggableScrollableActuator.setMin(panelKey.currentContext);
              } else if (state is home.MapOperatingState) {
                myWidget.DraggableScrollableActuator.setHide(panelKey.currentContext);
              }
            });
          },
        ),
      ],
      child: Updater(
        child: BlocBuilder<home.HomeBloc, home.HomeState>(
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomPadding: false,
              drawer: isDebug ? DrawerScenes() : null,
              bottomNavigationBar: BlocBuilder<home.HomeBloc, home.HomeState>(
                builder: (context, state) {
                  return Container(
                    height: state is home.MapOperatingState ? 0 : null,
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
                            _updateStatusBar();
                          });
                        },
                        currentIndex: _currentIndex,
                        items: [
                          BottomNavigationBarItem(title: Text(S.of(context).home_page), icon: Icon(Icons.home)),
                          BottomNavigationBarItem(
                              title: Text(S.of(context).wallet), icon: Icon(Icons.account_balance_wallet)),
                          BottomNavigationBarItem(title: Text(S.of(context).discover), icon: Icon(Icons.explore)),
                          BottomNavigationBarItem(
                              title: Text(S.of(context).information), icon: Icon(Icons.description)),
                          BottomNavigationBarItem(title: Text(S.of(context).my_page), icon: Icon(Icons.person)),
                        ]),
                  );
                },
              ),
              body: Stack(
                children: <Widget>[
                  //the map
                  LayoutBuilder(
                    builder: (ctx, BoxConstraints boxConstraints) {
                      return NotificationListener<myWidget.DraggableScrollableNotification>(
                          onNotification: (notification) {
                            if (state is home.MapOperatingState) {
                              var maxHeight = boxConstraints.biggest.height;
                              updateFabsPosition(
                                  notification.extent * maxHeight, notification.anchorExtent * maxHeight);
                            }
                            return true;
                          },
                          child: ScaffoldMap());
                    },
                  ),

                  //location
                  BottomFabsWidget(
                    key: fabsContainerKey,
                    showBurnBtn: state is InitialHomeState,
                  ),

                  buildMainSheetPanel(state),

                  //tab views
                  _getContent(_currentIndex),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    animationController.dispose();
    super.dispose();
  }

  Widget _getContent(int index) {
    switch (index) {
      case 1:
        return WalletContentWidget();
      case 2:
        return DiscoverContentWidget();
      case 3:
        return InformationContentWidget();
      case 4:
        return MyContentWidget();
    }
    return HomeScene();
  }

  Widget buildMainSheetPanel(home.HomeState state) {
    return myWidget.DraggableScrollableActuator(
      child: Builder(
        builder: (BuildContext context) {
          return SizedBox.expand(
            child: LayoutBuilder(
              builder: (ctx, BoxConstraints boxConstraints) {
                var maxHeight = boxConstraints.biggest.height;
                double anchorSize = 0.5;
                double minChildSize = 88.0 / maxHeight;
                double initSize = 280.0 / maxHeight;
                double maxChildSize = (maxHeight - MediaQuery.of(ctx).padding.top) / maxHeight;
                return NotificationListener<myWidget.DraggableScrollableNotification>(
                  onNotification: (notification) {
                    if (state is home.InitialHomeState) {
                      updateFabsPosition(notification.extent * maxHeight, notification.anchorExtent * maxHeight);
                    }
                    return true;
                  },
                  child: myWidget.DraggableScrollableSheet(
                    key: panelKey,
                    maxChildSize: maxChildSize,
                    expand: false,
                    minChildSize: minChildSize,
                    anchorSize: anchorSize,
                    initialChildSize: initSize,
                    draggable: true,
                    builder: (BuildContext ctx, ScrollController scrollController) {
                      return HomePanel(scrollController: scrollController);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void updateFabsPosition(double bottom, double anchorHeight) {
    var state = (fabsContainerKey.currentState is BottomFasScenesState)
        ? fabsContainerKey.currentState as BottomFasScenesState
        : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => state?.updateBottomPadding(bottom, anchorHeight));
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
        BlocProvider.of<ScaffoldMapBloc>(context)
            .add(SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
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
        BlocProvider.of<ScaffoldMapBloc>(context)
            .add(SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
      } catch (err) {
        logger.e(err);
      }
    }, onError: (err) {
      print(err);
    });
  }
}

class HomeScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
//    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    return Container();
  }
}
