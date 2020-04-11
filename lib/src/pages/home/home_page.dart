import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/home/home_panel.dart';
import 'package:titan/src/pages/news/info_detail_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import '../../widget/draggable_scrollable_sheet.dart' as myWidget;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return myWidget.DraggableScrollableActuator(
        child: BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
          listener: (context, state) {
            if (state is DefaultScaffoldMapState) {
              myWidget.DraggableScrollableActuator.setMin(context);
            } else {
              myWidget.DraggableScrollableActuator.setHide(context);
            }
          },
          child: BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(builder: (context, state) {
            return LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: <Widget>[
                  buildMainSheetPanel(context, constraints),
                ],
              );
            });
          }),
        ),
      );
  }

  Widget buildMainSheetPanel(context, boxConstraints) {
    double maxHeight = boxConstraints.biggest.height;
    double anchorSize = 0.5;
    double minChildSize = 88.0 / maxHeight;
    double initSize = 280.0 / maxHeight;
    EdgeInsets mediaPadding = MediaQuery.of(context).padding;
    double maxChildSize = (maxHeight - mediaPadding.top) / maxHeight;
    //hack, why maxHeight == 0 for the first time of release???
    if (maxHeight == 0.0) {
      return Container();
    }
    return myWidget.DraggableScrollableSheet(
      key: Keys.homePanelKey,
      maxHeight: maxHeight,
      maxChildSize: maxChildSize,
      expand: true,
      minChildSize: minChildSize,
      anchorSize: anchorSize,
      initialChildSize: initSize,
      draggable: true,
      builder: (BuildContext ctx, ScrollController scrollController) {
        return HomePanel(scrollController: scrollController);
      },
    );
  }


  @override
  void initState() {
    super.initState();

    TitanPlugin.msgPushChangeCallBack = (Map values) {
      _pushWebView(values);
    };

    TitanPlugin.urlLauncherCallBack = (Map values) {
      _urlLauncherAction(values);
    };
  }


  void _pushWebView(Map values) {
    var url = values["out_link"];
    var title = values["title"];
    var content = values["content"];
    print("[dd] content:${content}");

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InfoDetailPage(
              id: 0,
              url: url,
              title: title,
              content: content,
            )));
  }

  void _urlLauncherAction(Map values) {
    var type = values["type"];
    var subType = values["subType"];
    var content = values["content"];
    if (type == "contract" && subType == "detail") {
      print('[Home_page] _urlLauncherAction, values:${values}');

      var contractId = content["contractId"];
      var model = ContractNodeItem.onlyNodeId(int.parse(contractId));
      String jsonString = FluroConvertUtils.object2string(model.toJson());
      Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?model=${jsonString}");
    }
  }
}


//class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//  final GlobalKey _bottomBarKey = GlobalKey(debugLabel: 'bottomBarKey');
//  final GlobalKey fabsContainerKey = GlobalKey(debugLabel: 'fabsContainerKey');
//  final GlobalKey panelKey = GlobalKey(debugLabel: 'panelKey');
//
////  DraggableBottomSheetController _poiBottomSheetController = DraggableBottomSheetController();
//
//  StreamSubscription _appLinkSubscription;
//
//  var selectedAppArea = AppArea.MAINLAND_CHINA_AREA.key;
//
//  var _currentTabIndex = 0;
//  StreamSubscription _clearBadgeSubcription;
//
//  var _currentIndex = 0;
//
//  AnimationController animationController;
//
//  var isLoadAppArea = false;
//  var isShowSetAppAreaDialog = false;
//  var isShowAnnounceDialog = false;
//
//  @override
//  void initState() {
//    super.initState();
//    animationController = AnimationController(duration: Duration(milliseconds: 2000), vsync: this);
//
//    initUniLinks();
//
//    SchedulerBinding.instance.addPostFrameCallback((_) {
//      if (isShowSetAppAreaDialog == false) {
//        _loadAppArea();
//      }
//    });
//
//    Future.delayed(Duration(milliseconds: 2000)).then((value) {
//      Application.eventBus.fire(ToMyLocationEvent());
//      BlocProvider.of<home.HomeBloc>(context).add(home.HomeInitEvent());
//    });
//
//    TitanPlugin.msgPushChangeCallBack = (Map values) {
//      _pushWebView(values);
//    };
//
//    _clearBadgeSubcription = Application.eventBus.on().listen((event) {
//      print('[home] --> clear badge');
//      if (event is ClearBadgeEvent) {
//        BlocProvider.of<home.HomeBloc>(context).add(home.HomeInitEvent());
//      }
//    });
//  }
//
//  void _pushWebView(Map values) {
//    var url = values["out_link"];
//    var title = values["title"];
//    var content = values["content"];
//    print("[dd] content:${content}");
//
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) => InfoDetailPage(
//                  id: 0,
//                  url: url,
//                  title: title,
//                  content: content,
//                )));
//  }

//  void _showSetAreaAppDialog() {
//    showDialog(
//        context: context,
//        builder: (context) {
//          return AlertDialog(
//            content: SelecteAppAreaDialog(),
//          );
//        },
//        barrierDismissible: false);
//  }
//
//  void _loadAppArea() async {
//    isShowSetAppAreaDialog = true;
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String appAreaKey = prefs.getString(PrefsKey.appArea);
//    isLoadAppArea = true;
//    if (appAreaKey == null) {
//      _showSetAreaAppDialog();
//    } else {
//      appAreaChange(AppArea.APP_AREA_MAP[appAreaKey]);
//    }
//  }
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//
//    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
//    if (ModalRoute.of(context).isCurrent) {
//      _updateStatusBar();
//    } else {
//      //other route set status text to white color
////      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
//    }
//  }
//
//  void _updateStatusBar() {
//    if ([0, 1, 3].indexOf(_currentTabIndex) > -1) {
//      //status text black color
//      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
//    } else {
//      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    bool isDebug = env.buildType == BuildType.DEV;
//    return MultiBlocListener(
//      listeners: [
//        BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
//          listener: (context, state) {
//            if (state is InitialScaffoldMapState) {
//              BlocProvider.of<home.HomeBloc>(context).add(home.HomeInitEvent());
//            } else {
//              BlocProvider.of<home.HomeBloc>(context).add(home.MapOperatingEvent());
//            }
//          },
//        ),
//        BlocListener<home.HomeBloc, home.HomeState>(
//          listener: (context, state) {
//            //while listener trigger before build, the panelKey is not set, so call after build
//            WidgetsBinding.instance.addPostFrameCallback((_) {
//              if (state is InitialHomeState) {
//                myWidget.DraggableScrollableActuator.setMin(panelKey.currentContext);
//              } else if (state is home.MapOperatingState) {
//                myWidget.DraggableScrollableActuator.setHide(panelKey.currentContext);
//              }
//            });
//          },
//        ),
//      ],
//      child: UpdaterComponent(
//        child: BlocBuilder<home.HomeBloc, home.HomeState>(
//          builder: (context, state) {
//            if (state is InitialHomeState && state.announcement != null) {
//              print("!!!! isShowAnnounceDialog");
//              //todo 掘金 isShowAnnounceDialog 这里为 true
//              isShowAnnounceDialog = false;
//              isUpdateAnnounce = true;
//            }
//            return Scaffold(
//              resizeToAvoidBottomPadding: false,
//              drawer: isDebug ? DrawerComponent() : null,
//              bottomNavigationBar: BlocBuilder<home.HomeBloc, home.HomeState>(
//                builder: (context, state) {
//                  return Container(
//                    height: state is home.MapOperatingState ? 0 : null,
//                    child: BottomNavigationBar(
//                        key: _bottomBarKey,
//                        selectedItemColor: Theme.of(context).primaryColor,
//                        unselectedItemColor: Colors.black38,
//                        showUnselectedLabels: true,
//                        selectedFontSize: 12,
//                        unselectedFontSize: 12,
//                        type: BottomNavigationBarType.fixed,
//                        onTap: (index) {
//                          setState(() {
//                            _currentTabIndex = index;
//                            _updateStatusBar();
//                          });
//                        },
//                        currentIndex: _currentTabIndex,
//                        items: [
//                          BottomNavigationBarItem(title: Text(S.of(context).home_page), icon: Icon(Icons.home)),
//                          BottomNavigationBarItem(
//                              title: Text(S.of(context).wallet), icon: Icon(Icons.account_balance_wallet)),
//                          BottomNavigationBarItem(title: Text(S.of(context).discover), icon: Icon(Icons.explore)),
//                          BottomNavigationBarItem(
//                              title: Text(S.of(context).information),
//                              icon: Stack(
//                                children: <Widget>[
//                                  Icon(Icons.description),
//                                  if (isUpdateAnnounce)
//                                    Padding(
//                                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
//                                      child: Container(
//                                        height: 8,
//                                        width: 8,
//                                        decoration: BoxDecoration(
//                                            color: HexColor("#DA3B2A"),
//                                            shape: BoxShape.circle,
//                                            border: Border.all(color: HexColor("#DA3B2A"))),
//                                      ),
//                                    ),
//                                ],
//                              )),
//                          BottomNavigationBarItem(title: Text(S.of(context).my_page), icon: Icon(Icons.person)),
//                        ]),
//                  );
//                },
//              ),
//              body: Stack(
//                children: <Widget>[
//                  //the map
//                  LayoutBuilder(
//                    builder: (ctx, BoxConstraints boxConstraints) {
//                      return NotificationListener<myWidget.DraggableScrollableNotification>(
//                          onNotification: (notification) {
//                            if (state is home.MapOperatingState) {
//                              var maxHeight = boxConstraints.biggest.height;
//                              updateFabsPosition(
//                                  notification.extent * maxHeight, notification.anchorExtent * maxHeight);
//                            }
//                            return true;
//                          },
//                          child: ScaffoldMap());
//                    },
//                  ),
//
//                  //location
//                  BottomFabsWidget(
//                    key: fabsContainerKey,
//                    showBurnBtn: state is InitialHomeState,
//                  ),
//
//                  buildMainSheetPanel(state),
//
//                  //tab views
//                  _getViewContent(_currentTabIndex),
//
//                  if (isShowAnnounceDialog && state is InitialHomeState)
//                    AnnouncementDialog(state.announcement, () {
//                      isShowAnnounceDialog = false;
//                      isUpdateAnnounce = false;
//                      BlocProvider.of<home.HomeBloc>(context).add(home.HomeInitEvent());
//                    }),
//                ],
//              ),
//            );
//          },
//        ),
//      ),
//    );
//  }
//
//  @override
//  void dispose() {
//    _clearBadgeSubcription?.cancel();
//    _appLinkSubscription?.cancel();
//    animationController.dispose();
//    super.dispose();
//  }
//
//  Widget _getViewContent(int index) {
//    switch (index) {
//      case 1:
//        return WalletContentWidget();
//      case 2:
//        return DiscoverContentWidget();
//      case 3:
//        return InformationContentWidget();
//      case 4:
//        return MyContentWidget();
//    }
//    return HomeScene();
//  }
//
//  Widget buildMainSheetPanel(home.HomeState state) {
//    return myWidget.DraggableScrollableActuator(
//      child: Container(
//        constraints: BoxConstraints.expand(),
//        child: LayoutBuilder(
//          builder: (ctx, BoxConstraints boxConstraints) {
//            double maxHeight = boxConstraints.biggest.height;
//            double anchorSize = 0.5;
//            double minChildSize = 88.0 / maxHeight;
//            double initSize = 280.0 / maxHeight;
//            double maxChildSize = (maxHeight - MediaQuery.of(ctx).padding.top) / maxHeight;
////            var pheight = MediaQuery.of(ctx).removePadding(removeBottom: true, removeTop: true).size.height - 56;
////            Fluttertoast.showToast(msg: 'xxx height $maxHeight, $pheight');
//            //hack, why maxHeight == 0 for the first time of release???
//            if (maxHeight == 0.0) {
//              return Container();
//            }
//            return NotificationListener<myWidget.DraggableScrollableNotification>(
//              onNotification: (notification) {
//                if (state is home.InitialHomeState) {
//                  updateFabsPosition(notification.extent * maxHeight, notification.anchorExtent * maxHeight);
//                }
//                return true;
//              },
//              child: myWidget.DraggableScrollableSheet(
//                key: panelKey,
//                maxChildSize: maxChildSize,
//                expand: true,
//                minChildSize: minChildSize,
//                anchorSize: anchorSize,
//                initialChildSize: initSize,
//                draggable: true,
//                builder: (BuildContext ctx, ScrollController scrollController) {
//                  return HomePanel(scrollController: scrollController);
//                },
//              ),
//            );
//          },
//        ),
//      ),
//    );
//  }
//
//  void updateFabsPosition(double bottom, double anchorHeight) {
//    var state = (fabsContainerKey.currentState is BottomFasScenesState)
//        ? fabsContainerKey.currentState as BottomFasScenesState
//        : null;
//    WidgetsBinding.instance.addPostFrameCallback((_) => state?.updateBottomPadding(bottom, anchorHeight));
//  }
//
//  Future<Null> initUniLinks() async {
//    try {
//      String initialLink = await getInitialLink();
//      print("initialLink listen url $initialLink");
//
//      try {
//        if (initialLink == null || initialLink.isEmpty) {
//          return;
//        }
//        IPoi poi = await ciphertextToPoi(Injector.of(context).repository, initialLink.toString());
//        BlocProvider.of<ScaffoldMapBloc>(context)
//            .add(SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
//      } catch (err) {
//        logger.e(err);
//      }
//      // Parse the link and warn the user, if it is not correct,
//      // but keep in mind it could be `null`.
//    } on PlatformException {
//      // Handle exception by warning the user their action did not succeed
//      // return?
//    }
//
//    // Attach a listener to the stream
//    _appLinkSubscription = getLinksStream().listen((String link) async {
//      print("listenlink listen url $link");
//
//      try {
//        IPoi poi = await ciphertextToPoi(Injector.of(context).repository, link.toString());
//        BlocProvider.of<ScaffoldMapBloc>(context)
//            .add(SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
//      } catch (err) {
//        logger.e(err);
//      }
//    }, onError: (err) {
//      print(err);
//    });
//  }
//}
//
//class HomeScene extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
////    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
////    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
//    return Container();
//  }
//}