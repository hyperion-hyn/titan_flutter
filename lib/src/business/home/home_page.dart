import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/home/sheets/bloc/bloc.dart' as sheets;
import 'package:titan/src/business/home/sheets/sheets.dart';

import 'package:titan/src/business/search/search_page.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';
import 'bootom_opt_bar_widget.dart';
import 'map/map_scenes.dart';
import 'bottom_fabs_widget.dart';
import 'drawer/drawer_scenes.dart';
import 'searchbar/searchbar.dart';

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _lastPressedAt;
  DraggableBottomSheetController _draggableBottomSheetController = DraggableBottomSheetController();

  StreamSubscription _appLinkSubscription;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context).isCurrent) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      MapScenes(),

                      ///主要是支持drawer手势划出
                      Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        constraints: BoxConstraints.tightForFinite(width: 24.0),
                      ),

                      BottomFabsWidget(draggableBottomSheetController: _draggableBottomSheetController),

                      ///bottom sheet
                      Sheets(
                        draggableBottomSheetController: _draggableBottomSheetController,
                      ),

                      ///搜索入口
                      SearchBarPresenter(
                        draggableBottomSheetController: _draggableBottomSheetController,
                        onMenu: () => Scaffold.of(context).openDrawer(),
                        backToPrvSearch: (String searchText, List<dynamic> pois) {
                          BlocProvider.of<HomeBloc>(context)
                              .dispatch(SearchTextEvent(searchText: searchText, pois: pois));
                        },
                        onExistSearch: () => BlocProvider.of<HomeBloc>(context).dispatch(ExistSearchEvent()),
                        onSearch: (searchText) async {
                          var center = LatLng(23.108317, 113.316121); //test TODO
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
                            BlocProvider.of<HomeBloc>(context).dispatch(ShowPoiEvent(poi: searchResult));
                          }
                        },
                      ),

                      ///路线规划， 分析操作区
                      BlocBuilder<sheets.SheetsBloc, sheets.SheetsState>(
                        builder: (context, state) {
                          if (state is sheets.PoiLoadedState || state is sheets.HeavenPoiLoadedState) {
                            return BottomOptBarWidget(
                              onRouteTap: () {
                                print('route TODO');
                              },
                              onShareTap: () {
                                print('shaer TODO');
                              },
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  )),
        ));
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    super.dispose();
  }

  Future<Null> initUniLinks() async {
    // Attach a listener to the stream
    _appLinkSubscription = getUriLinksStream().listen((Uri uri) {
//      TODO 完成解码的操作
      print("applink listen url $uri");
    }, onError: (err) {
      print(err);
    });
  }
}
