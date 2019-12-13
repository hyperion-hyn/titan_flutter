import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/scaffold_map/bottom_panels/gaode_poi_panel.dart';
import 'package:titan/src/business/search/search_page.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/model/gaode_poi.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';
import 'bottom_panels/common_panel.dart';
import 'bottom_panels/poi_panel.dart';
import 'bottom_panels/route_panel.dart';
import 'bottom_panels/search_list_panel.dart';
import 'map.dart';
import 'opt_bar.dart';
import 'search_bar.dart';
import 'top_bar.dart';
import 'route_bar.dart';

//final kStyleZh = 'https://cn.tile.map3.network/see-it-all-boundary-cdn-zh.json';

final kStyleZh = 'https://cn.tile.map3.network/see-it-all-boundary-cdn-en.json';

final kStyleEn = 'https://static.hyn.space/maptiles/see-it-all-boundary-cdn-en.json';

typedef PanelBuilder = Widget Function(BuildContext context, ScrollController scrollController, IDMapPoi poi);

typedef HeightCallBack = void Function(double height);

class ScaffoldMap extends StatefulWidget {
  final DraggableBottomSheetController poiBottomSheetController;

  ScaffoldMap({
    this.poiBottomSheetController,
  });

  @override
  State<StatefulWidget> createState() {
    return _ScaffoldMapState();
  }
}

class _ScaffoldMapState extends State<ScaffoldMap> {
  ScrollController _bottomChildScrollController = ScrollController();

  StreamSubscription _eventbusSubcription;

  double topBarHeight = 0;

  @override
  void initState() {
    super.initState();
    _eventbusSubcription = eventBus.on().listen(eventBusListener);
  }

  void eventBusListener(event) async {
    if (event is GoSearchEvent) {
      var mapScenseState = Keys.mapContainerKey.currentState as MapContainerState;
      var camraPosition = await mapScenseState.mapboxMapController.getCameraPosition();
      var center = camraPosition.target;

      var searchResult = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchPage(
                    searchCenter: center,
                    searchText: event.searchText,
                  )));

      BlocProvider.of<ScaffoldMapBloc>(context).add(InitMapEvent());

      if (searchResult is String) {
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(searchText: searchResult, center: center));
      } else if (searchResult is PoiEntity) {
        var poi = searchResult;
        if (searchResult.address == null) {
          //we need to full fil all properties
          BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: poi));
        } else {
          BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
        }
      }
    }
  }

  @override
  void dispose() {
    _eventbusSubcription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    //scenes:
    //1. map
    //2. top navigation bar
    //3. search bar
    //4. route bar
    //5. bottom sheet
    //6. bottom operation bar
    //logic:  use prop to update each scene. scene use bloc to update data/state.
    return BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(builder: (context, state) {
      print('bloc builder: $state');
      var languageCode = Localizations.localeOf(context).languageCode;

      //---------------------------
      //set map
      //---------------------------
      bool showCenterMarker = false;
      String style = kStyleEn;
      if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key) {
        style = kStyleZh;
      } else {
        style = kStyleEn;
      }
      if (state.dMapConfigModel?.showCenterMarker == true) {
        showCenterMarker = true;
      }
//        var mapState =
//      if (state is InitialScaffoldMapState) {}

      //---------------------------
      //set topbar
      //---------------------------
      bool showTopBar = false;
      VoidCallback onTopBarBack;
      VoidCallback onTopBarClose;
      String title = '';
      if (state is SearchingPoiByTextState || state is SearchPoiByTextSuccessState) {
        showTopBar = true;
        title = state.getSearchText();
        onTopBarClose = () {
          BlocProvider.of<ScaffoldMapBloc>(context).add(InitMapEvent());
        };
        onTopBarBack = () {
          eventBus.fire(GoSearchEvent());
        };
      }

      //---------------------------
      //set search bar
      //---------------------------
      String searchText = '';
      bool showSearchBar = false;
      if (state is SearchingPoiByTextState || state is SearchPoiByTextSuccessState) {
        showSearchBar = true;
        searchText = state.getSearchText();
      }

      //---------------------------
      //set route
      //---------------------------
      bool showRoute = false;
      IPoi fromPoi;
      IPoi toPoi;
      String profile;
      String language;
      RouteDataModel routeDataModel;
      if (state is RoutingState) {
        showRoute = true;
        fromPoi = state.fromPoi;
        toPoi = state.toPoi;
        profile = state.profile;
        language = state.language;
      } else if (state is RouteSuccessState) {
        showRoute = true;
        fromPoi = state.fromPoi;
        toPoi = state.toPoi;
        profile = state.profile;
        language = state.language;
        routeDataModel = state.routeDataModel;
      } else if (state is RouteFailState) {
        showRoute = true;
        fromPoi = state.fromPoi;
        toPoi = state.toPoi;
        profile = state.profile;
        language = state.language;
      }

      //---------------------------
      //set the bottom sheet
      //---------------------------
      double topPadding = MediaQuery.of(context).padding.top;
      double topRadius = 0;
      bool draggable = false;
      Widget sheetPanel;
      double collapsedHeight = kCollapsedHeight;
      double anchorHeight = kAnchorPoiHeight;

      DraggableBottomSheetState dragState = DraggableBottomSheetState.HIDDEN;

      if (state is InitialScaffoldMapState) {
        //nothing
      } else if (state is SearchingPoiState) {
        //查找POI
        sheetPanel = LoadingPanel();
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is ShowPoiState) {
        //显示poi
        draggable = true;
        topRadius = 16;
//        topPadding = MediaQuery.of(context).padding.top;

        //dmap poi panel (by config)
        if (state.dMapConfigModel?.panelBuilder != null && state.getCurrentPoi() is IDMapPoi) {
          if (state.dMapConfigModel?.panelPaddingTop != null) {
            topPadding = state.dMapConfigModel?.panelPaddingTop(context);
          }
          sheetPanel =
              state.dMapConfigModel?.panelBuilder(context, _bottomChildScrollController, state.getCurrentPoi());
        }

        if (sheetPanel == null) {
          if (state.getCurrentPoi() is PoiEntity) {
            sheetPanel = PoiPanel(
              scrollController: _bottomChildScrollController,
              selectedPoiEntity: state.getCurrentPoi(),
            );
          } else if (state.getCurrentPoi() is GaodePoi) {
            sheetPanel = GaodePoiPanel(
              scrollController: _bottomChildScrollController,
              poi: state.getCurrentPoi(),
            );
          }
        }

        collapsedHeight = widget.poiBottomSheetController.collapsedHeight;
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is SearchPoiFailState) {
        //搜索poi失败
        sheetPanel = FailPanel(
          message: state.message,
          showCloseBtn: true,
        );
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is SearchingPoiByTextState) {
        //搜索POI
        sheetPanel = LoadingPanel();
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is SearchPoiByTextSuccessState) {
        //搜索成功
        draggable = true;
        topRadius = 16;
        topPadding = topBarHeight - 12; //减去"抓" 的范围
        if (state.getSearchPoiList() != null && state.getSearchPoiList().length > 0) {
          dragState = DraggableBottomSheetState.ANCHOR_POINT;
        } else {
          dragState = DraggableBottomSheetState.COLLAPSED;
        }

        sheetPanel = SearchListPanel(
          scrollController: _bottomChildScrollController,
          pois: state.getSearchPoiList(),
        );
      } else if (state is SearchPoiByTextFailState) {
        //搜索失败
        sheetPanel = FailPanel(
          message: state.message,
          showCloseBtn: true,
        );
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is RoutingState) {
        //路线规划中
        sheetPanel = LoadingPanel();
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is RouteSuccessState) {
        //路线规划成功
        sheetPanel = RoutePanel(
          routeDataModel: routeDataModel,
          profile: profile,
        );
        dragState = DraggableBottomSheetState.COLLAPSED;
      } else if (state is RouteFailState) {
        //路线规划失败
        sheetPanel = FailPanel(
          message: state.message,
          showCloseBtn: false,
        );
        dragState = DraggableBottomSheetState.COLLAPSED;
      }

      //for dmap, always show sheet panel
      if (sheetPanel == null &&
          state.dMapConfigModel?.alwaysShowPanel == true &&
          state.dMapConfigModel?.panelBuilder != null) {
        sheetPanel = state.dMapConfigModel?.panelBuilder(context, _bottomChildScrollController, null);
        if (state.dMapConfigModel?.panelPaddingTop != null) {
          topPadding = state.dMapConfigModel?.panelPaddingTop(context);
        }
        dragState = DraggableBottomSheetState.COLLAPSED;
      }
      if (state.dMapConfigModel?.panelDraggable == true) {
        draggable = true;
        topRadius = 16;
      }
      if (state.dMapConfigModel?.panelAnchorHeight != null) {
        anchorHeight = state.dMapConfigModel?.panelAnchorHeight;
      }
      if (state.dMapConfigModel?.panelCollapsedHeight != null) {
        collapsedHeight = state.dMapConfigModel?.panelCollapsedHeight;
      }

      widget.poiBottomSheetController?.collapsedHeight = collapsedHeight;
      widget.poiBottomSheetController.anchorHeight = anchorHeight;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.poiBottomSheetController?.setSheetState(dragState);
      });

      //---------------------------
      //set opt bar
      //---------------------------
      bool showOptBar = false;
      if (state is ShowPoiState) {
        showOptBar = true;
      }

      //---------------------------
      // dmap
      //---------------------------
      List<HeavenDataModel> heavenModelList = state.dMapConfigModel?.heavenDataModelList;
      OnMapClickHandle onMapClickHandle;
      OnMapLongPressHandle onMapLongPressHandle;
      onMapClickHandle = state.dMapConfigModel?.onMapClickHandle;
      onMapLongPressHandle = state.dMapConfigModel?.onMapLongPressHandle;

      return Stack(
        children: <Widget>[
          Container(), //need a container to expand the stack???
          MapContainer(
            key: Keys.mapContainerKey,
            heavenDataList: heavenModelList,
            bottomPanelController: widget.poiBottomSheetController,
            style: style,
            routeDataModel: routeDataModel,
            mapClickHandle: onMapClickHandle,
            mapLongPressHandle: onMapLongPressHandle,
            showCenterMarker: showCenterMarker,
            languageCode: languageCode,
          ),
//          if (showSearchBar)
//            SearchBar(
//              searchText: searchText,
//              bottomPanelController: widget.poiBottomSheetController,
//            ),
          if (showRoute)
            RouteBar(
              fromName: fromPoi.name,
              toName: toPoi.name,
              profile: profile,
              onBack: () {
                BlocProvider.of<ScaffoldMapBloc>(context).add(ExistRouteEvent());
              },
              onRoute: (String toProfile) {
                BlocProvider.of<ScaffoldMapBloc>(context).add(RouteEvent(
                  fromPoi: fromPoi,
                  toPoi: toPoi,
                  profile: toProfile,
                  language: language,
                ));
              },
            ),
          /* bottom sheet */
          DraggableBottomSheet(
            draggable: draggable,
            topPadding: topPadding,
            topRadius: topRadius,
            controller: widget.poiBottomSheetController,
            childScrollController: _bottomChildScrollController,
            child: sheetPanel ?? Container(),
          ),
//          if (showTopBar)
//            TopBar(
//              title: title,
//              onBack: onTopBarBack,
//              onClose: onTopBarClose,
//              bottomPanelController: widget.poiBottomSheetController,
//              heightCallBack: (double height) {
////              setState(() {
//                topBarHeight = height;
////              });
//              },
//            ),
          if (showOptBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: OperationBar(
                onRouteTap: tapRoute,
              ),
            ),
        ],
      );
    });
  }

  void tapRoute() async {
    var currentPoi = ScaffoldMapStore.shared.currentPoi;
    var location = await getMapState?.mapboxMapController?.lastKnownLocation();
    if (currentPoi != null) {
      if (location == null) {
        Fluttertoast.showToast(msg: '获取不到你当前位置');
      } else {
        var fromPoi = PoiEntity(latLng: location, name: S.of(context).my_location);
        var toPoi = currentPoi;
        var language = Localizations.localeOf(context).languageCode;
        var profile = 'driving';
        BlocProvider.of<ScaffoldMapBloc>(context).add(RouteEvent(
          fromPoi: fromPoi,
          toPoi: toPoi,
          language: language,
          profile: profile,
        ));
      }
    }
  }

  MapContainerState get getMapState {
    return Keys.mapContainerKey.currentState as MapContainerState;
  }
}
