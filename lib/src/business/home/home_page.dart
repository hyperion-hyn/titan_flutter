import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/home/sheets/poi_bottom_sheet.dart';
import 'package:titan/src/business/home/sheets/search_fault_sheet.dart';

import 'package:titan/src/business/search/search_page.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';
import 'map_scenes.dart';
import 'bottom_fabs_scenes.dart';
import 'drawer_scenes.dart';
import 'sheets/searching_sheet.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _lastPressedAt;
  DraggableBottomSheetController _draggableBottomSheetController = DraggableBottomSheetController(collapsedHeight: 110);
  ScrollController _bottomSheetScrollController = ScrollController();

  StreamSubscription _homeBlocSubscription;

  final TextEditingController _searchTextController = TextEditingController();

  void _showPoi(dynamic poi) {
    BlocProvider.of<HomeBloc>(context)?.dispatch(SelectedPoiEvent(selectedPoi: poi));
  }

  void _searchText(String text, LatLng center) {
    BlocProvider.of<HomeBloc>(context)?.dispatch(SearchPoiListEvent(
      searchText: text,
      center: '${center.longitude},${center.latitude}',
      language: Localizations.localeOf(context).languageCode,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeBlocSubscription?.cancel();
    _homeBlocSubscription = BlocProvider.of<HomeBloc>(context)?.state?.listen((HomeState state) {
      if (state is BottomSheetState) {
        if (state.state != null) {
          _draggableBottomSheetController.setSheetState(state.state);
        }
      } else if (state is HomeSearchState) {
        if (state.isInSearchMode == true && state.isFetching == true) {
          _searchTextController.text = state.searchText;
        } else if (state.isInSearchMode != true) {
          _searchTextController.text = '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                builder: (BuildContext ctx) => Stack(
                      children: <Widget>[
                        ///地图渲染
                        MapScenes(
                          homeBloc: BlocProvider.of<HomeBloc>(context),
                          language: Localizations.localeOf(context).languageCode,
                        ),

                        ///搜索入口
                        buildSearchWidget(ctx),

                        ///主要是支持drawer手势划出
                        Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          constraints: BoxConstraints.tightForFinite(width: 24.0),
                        ),

                        BottomFabsScenes(draggableBottomSheetController: _draggableBottomSheetController),

                        ///bottom sheet
                        DraggableBottomSheet(
                            controller: _draggableBottomSheetController,
                            childScrollController: _bottomSheetScrollController,
                            child: BlocBuilder(
                              bloc: BlocProvider.of<HomeBloc>(context),
                              condition: (pre, current) {
                                return current is BottomSheetState || current is HomeSearchState;
                              },
                              builder: (context, HomeState state) {
                                Widget sheet;
                                if (state is BottomSheetState) {
                                  if (state.isFetchingPoiInfo == true) {
                                    sheet = SearchingBottomSheet();
                                  } else if (state.isFetchFault == true) {
                                    sheet = SearchFaultBottomSheet();
                                  } else if (state.isFetchingPoiInfo != true && state.selectedPoi != null) {
                                    //扩展这里，添加不同poi style
                                    if (state.selectedPoi is PoiEntity) {
                                      sheet = PoiBottomSheet(state.selectedPoi);
                                    }
                                  }
                                } else if (state is HomeSearchState) {
                                  if (state.isFetching == true) {
                                    sheet = SearchingBottomSheet();
                                  } else if (state.isSearchFault == true) {
                                    sheet = SearchFaultBottomSheet();
                                  } else if (state.isFetching != true && state.searchResultItems != null) {
                                    //TODO
                                    sheet = Text('得到一些记录 ${state.searchResultItems.length}');
                                  }
                                }

                                if (sheet == null) {
                                  sheet = SearchingBottomSheet();
                                }

                                return Stack(
                                  children: <Widget>[sheet],
                                );
                              },
                            ))
                      ],
                    )),
          )),
    );
  }

  ///搜索控件
  Widget buildSearchWidget(context) {
    return Container(
      margin: EdgeInsets.only(top: 24, left: 16, right: 16),
      constraints: BoxConstraints.tightForFinite(height: 48),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        elevation: 2.0,
        child: BlocBuilder(
          bloc: BlocProvider.of<HomeBloc>(context),
          condition: (previous, current) {
            return current is HomeSearchState;
          },
          builder: (context, state) {
            return Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.menu, color: Colors.grey[600]),
                  ),
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () async {
                    var center = LatLng(23.108317, 113.316121); //test TODO
                    var searchResult = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchPage(
                                  searchCenter: center,
                                  searchText: _searchTextController.text,
//                          searchText: '中华人民共和国', //test
                                )));
                    if (searchResult is String) {
                      _searchText(searchResult, center);
                    } else if (searchResult is PoiEntity) {
                      _showPoi(searchResult);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    color: Colors.transparent,
                    child: TextField(
                        controller: _searchTextController,
                        enabled: false,
                        decoration: InputDecoration(hintText: '搜索 / 解码', border: InputBorder.none),
                        style: Theme.of(context).textTheme.body1),
                  ),
                )),
                if (state is HomeSearchState && state.isFetching)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                if (state is HomeSearchState && state.isInSearchMode)
                  InkWell(
                      onTap: () {
                        setState(() {
                          BlocProvider.of<HomeBloc>(context).dispatch(ClearSearchMode());
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                        ),
                      ))
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeBlocSubscription?.cancel();
    super.dispose();
  }
}
