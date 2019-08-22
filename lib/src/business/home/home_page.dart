import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/business/home/improvement_dialog.dart';
import 'package:titan/src/business/home/intro/intro_slider.dart';
import 'package:titan/src/business/home/searchbar/bloc/bloc.dart' as search;
import 'package:titan/src/business/home/sheets/bloc/bloc.dart' as sheets;
import 'package:titan/src/business/home/sheets/sheets.dart';
import 'package:titan/src/business/home/bloc/bloc.dart' as home;

import 'package:titan/src/business/search/search_page.dart';
import 'package:titan/src/business/updater/updater.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/utils/encryption.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../global.dart';
import 'bloc/bloc.dart';
import 'bootom_opt_bar_widget.dart';
import 'map/bloc/bloc.dart';
import 'map/map_scenes.dart';
import 'bottom_fabs_widget.dart';
import 'drawer/drawer_scenes.dart';
import 'searchbar/searchbar.dart';

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'share_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _lastPressedAt;
  DraggableBottomSheetController _draggableBottomSheetController = DraggableBottomSheetController();

  StreamSubscription _appLinkSubscription;

  GlobalKey mapScenseKey = GlobalKey();

  var isFirst;
  var isShowPlanDialog;
  var isShowIntro = false;
  var isPlanDialogIsShowing = false;

  @override
  void initState() {
    super.initState();
    initUniLinks();
    print("initState");
    _isNeedShowIntro();
    _isNeedShowPlanDialog();
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

  void _isNeedShowIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirst = prefs.getBool('isFirstRun') ?? true;
    print('isFirstRun: $isFirst');
    setState(() {});
  }

  void _isNeedShowPlanDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isShowPlanDialog = prefs.getBool('isShowPlanDialog') ?? false;
    print('isShowPlanDialog: $isFirst');
    setState(() {});
  }

  void _savePlanDialogState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isShowPlanDialog', true);
//    setState(() {});
    _isNeedShowIntro();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (isFirst == true && !isShowIntro) {
        isShowIntro = true;
        Navigator.push(context, MaterialPageRoute(builder: (context) => IntroScreen())).then((data) {
          _isNeedShowIntro();
          if (isShowPlanDialog == false && !isPlanDialogIsShowing) {
            isPlanDialogIsShowing = true;
            showDialog(
                context: context,
                builder: (context) {
                  return ImprovementDialog();
                });

            _savePlanDialogState();
          }
        });
      }
    });

    if (isFirst == null) {
      return Container(
        color: Colors.white,
      );
    }
    if (isFirst) {
      return Container(
        color: Colors.white,
      );
    }
    return Updater(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          drawer: DrawerScenes(),
          body: WillPopScope(
            onWillPop: () async {
              if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
                _lastPressedAt = DateTime.now();
                Fluttertoast.showToast(msg: '再按一下退出程序');
                return false;
              }
              return true;
            },
            child: Builder(
                builder: (BuildContext context) => Stack(
                      children: <Widget>[
                        ///地图渲染
                        MapScenes(
                          draggableBottomSheetController: _draggableBottomSheetController,
                          key: mapScenseKey,
                        ),

                        ///主要是支持drawer手势划出
                        Container(
                          margin: EdgeInsets.only(top: 120),
                          decoration: BoxDecoration(color: Colors.transparent),
                          constraints: BoxConstraints.tightForFinite(width: 24.0),
                        ),

                        BottomFabsWidget(draggableBottomSheetController: _draggableBottomSheetController),

                        ///bottom sheet
                        Sheets(
                          draggableBottomSheetController: _draggableBottomSheetController,
                        ),

                        ///search bar
                        SearchBarPresenter(
                          draggableBottomSheetController: _draggableBottomSheetController,
                          onMenu: () => Scaffold.of(context).openDrawer(),
                          backToPrvSearch: (String searchText) {
                            BlocProvider.of<HomeBloc>(context).dispatch(SearchTextEvent(searchText: searchText));
                          },
                          onExistSearch: () => BlocProvider.of<HomeBloc>(context).dispatch(ExistSearchEvent()),
                          onSearch: (searchText) async {
                            var mapScenseState = mapScenseKey.currentState as MapScenesState;
                            print("get mapScenseState ");
                            var camraPosition = await mapScenseState.mapboxMapController.getCameraPosition();
                            print("search center $camraPosition");
                            var center = camraPosition.target;
                            print("search center $center");
                            var searchResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage(
                                          searchCenter: center,
                                          searchText: searchText,
                                        )));
                            if (searchResult is String) {
                              BlocProvider.of<HomeBloc>(context)
                                  .dispatch(SearchTextEvent(searchText: searchResult, center: center));
                            } else if (searchResult is PoiEntity) {
                              if (searchResult.address == null) {
                                //we need to full fil all properties
                                BlocProvider.of<HomeBloc>(context).dispatch(SearchPoiEvent(poi: searchResult));
                              } else {
                                BlocProvider.of<HomeBloc>(context).dispatch(ShowPoiEvent(poi: searchResult));
                              }
                            }
                          },
                        ),

                        ///opt area
                        BlocBuilder<sheets.SheetsBloc, sheets.SheetsState>(
                          builder: (context, state) {
                            if (state is sheets.PoiLoadedState || state is sheets.HeavenPoiLoadedState) {
                              return BottomOptBarWidget(
                                onRouteTap: () {
//                                BlocProvider.of<HomeBloc>(context).dispatch(RouteEvent());
                                  eventBus.fire(RouteClickEvent());
                                },
                                onShareTap: () async {
                                  var selectedPoi = BlocProvider.of<HomeBloc>(context).selectedPoi;
                                  if (selectedPoi != null) {
                                    var dat = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ShareDialog(poi: selectedPoi);
                                        });
                                  }
                                },
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ],
                    )),
          )),
    );
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    super.dispose();
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
            .dispatch(home.SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
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
            .dispatch(home.SearchPoiEvent(poi: PoiEntity(latLng: poi.latLng, name: poi.name)));
      } catch (err) {
        logger.e(err);
      }
    }, onError: (err) {
      print(err);
    });
  }
}
