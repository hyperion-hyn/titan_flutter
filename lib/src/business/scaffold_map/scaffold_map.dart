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
import 'package:titan/src/business/position/model/confirm_poi_item.dart';
import 'package:titan/src/business/scaffold_map/bottom_panels/gaode_poi_panel.dart';
import 'package:titan/src/business/search/search_page.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/model/gaode_poi.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/widget/header_height_notification.dart';

import '../../widget/draggable_scrollable_sheet.dart' as myWidget;
import 'bloc/bloc.dart';
import 'bottom_panels/common_panel.dart';
import 'bottom_panels/poi_panel.dart';
import 'bottom_panels/route_panel.dart';
import 'bottom_panels/search_list_panel.dart';
import 'bottom_panels/user_poi_panel.dart';
import 'map.dart';
import 'opt_bar.dart';
import 'route_bar.dart';

typedef PanelBuilder = Widget Function(BuildContext context, ScrollController scrollController, IDMapPoi poi);
typedef SheetPanelBuilder = Widget Function(BuildContext context, ScrollController scrollController);

typedef HeightCallBack = void Function(double height);

class ScaffoldMap extends StatefulWidget {
//  final DraggableBottomSheetController poiBottomSheetController;
//
//  ScaffoldMap({
//    this.poiBottomSheetController,
//  });

  @override
  State<StatefulWidget> createState() {
    return _ScaffoldMapState();
  }
}

class _ScaffoldMapState extends State<ScaffoldMap> {
//  ScrollController _bottomChildScrollController = ScrollController();
  final GlobalKey poiDraggablePanelKey = GlobalKey(debugLabel: 'poiDraggablePanelKey');

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
      } else if (searchResult is PoiEntity || searchResult is ConfirmPoiItem) {
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
    //scenes:
    //1. map
    //2. top navigation bar
    //3. search bar
    //4. route bar
    //5. bottom sheet
    //6. bottom operation bar
    //logic:  use prop to update each scene. scene use bloc to update data/state.
    return LayoutBuilder(builder: (ctx, BoxConstraints boxConstraints) {
      return BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(builder: (context, state) {
        var languageCode = Localizations.localeOf(context).languageCode;
        double maxHeight = boxConstraints.biggest.height;

        //---------------------------
        //set map
        //---------------------------
        bool showCenterMarker = false;
        String style;
        if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key) {
          style = Const.kWhiteMapStyleCn;
        } else {
          style = Const.kWhiteMapStyle;
        }
        if (state.dMapConfigModel?.showCenterMarker == true) {
          showCenterMarker = true;
        }

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
        bool draggable = false;
        SheetPanelBuilder panelBuilder;
        double collapsedHeight = 140;
        double anchorHeight = maxHeight * 0.55;
        double initHeight = 0;

        if (state is InitialScaffoldMapState) {
          //nothing
        } else if (state is SearchingPoiState) {
          //search POI detail
          panelBuilder = (context, controller) => LoadingPanel(scrollController: controller);
          initHeight = collapsedHeight;
        } else if (state is ShowPoiState) {
          draggable = true;
          //dMap poi panel (by config)
          if (state.dMapConfigModel?.panelBuilder != null && state.getCurrentPoi() is IDMapPoi) {
            panelBuilder =
                (context, controller) => state.dMapConfigModel.panelBuilder(context, controller, state.getCurrentPoi());

            if (state.dMapConfigModel.panelPaddingTop != null) {
              topPadding = state.dMapConfigModel?.panelPaddingTop(context);
            }
          }

          if (panelBuilder == null) {
            if (state.getCurrentPoi() is PoiEntity) {
              panelBuilder = (context, controller) => PoiPanel(
                    scrollController: controller,
                    selectedPoiEntity: state.getCurrentPoi(),
                  );
            } else if (state.getCurrentPoi() is GaodePoi) {
              panelBuilder = (context, controller) => GaodePoiPanel(
                    scrollController: controller,
                    poi: state.getCurrentPoi(),
                  );
            } else if (state.getCurrentPoi() is ConfirmPoiItem) {
              panelBuilder = (context, controller) => UserPoiPanel(
                    scrollController: controller,
                    selectedPoiEntity: state.getCurrentPoi(),
                  );
            }
          }
          initHeight = collapsedHeight;
        } else if (state is SearchPoiFailState) {
          //search poi fail
          panelBuilder = (context, controller) => FailPanel(
                message: state.message,
                showCloseBtn: true,
                scrollController: controller,
              );
          initHeight = collapsedHeight;
        } else if (state is SearchingPoiByTextState) {
          //search POI by text.
          panelBuilder = (context, controller) => LoadingPanel(scrollController: controller);
          initHeight = collapsedHeight;
        } else if (state is SearchPoiByTextSuccessState) {
          //search success
          draggable = true;
          topPadding = topBarHeight + 12; //minus "drag" height 12
          if (state.getSearchPoiList() != null && state.getSearchPoiList().length > 0) {
            initHeight = anchorHeight;
          } else {
            initHeight = collapsedHeight;
          }

          panelBuilder =
              (context, controller) => SearchListPanel(scrollController: controller, pois: state.getSearchPoiList());
        } else if (state is SearchPoiByTextFailState) {
          //search fail
          panelBuilder = (context, controller) => FailPanel(
                message: state.message,
                showCloseBtn: true,
                scrollController: controller,
              );
          initHeight = collapsedHeight;
        } else if (state is RoutingState) {
          //route on progress
          panelBuilder = (context, controller) => LoadingPanel(
                scrollController: controller,
              );
          initHeight = collapsedHeight;
        } else if (state is RouteSuccessState) {
          //route success
          panelBuilder = (context, controller) => RoutePanel(
                routeDataModel: routeDataModel,
                profile: profile,
                scrollController: controller,
              );
          initHeight = collapsedHeight;
        } else if (state is RouteFailState) {
          //route fail
          panelBuilder = (context, controller) => FailPanel(
                message: state.message,
                showCloseBtn: false,
                scrollController: controller,
              );
          initHeight = collapsedHeight;
        }

        //for dMap, always show sheet panel, for now mainly for share Encrypted location Share
        if (panelBuilder == null &&
            state.dMapConfigModel?.alwaysShowPanel == true &&
            state.dMapConfigModel?.panelBuilder != null) {
          panelBuilder = (context, controller) => state.dMapConfigModel.panelBuilder(context, controller, null);
          if (state.dMapConfigModel?.panelPaddingTop != null) {
            topPadding = state.dMapConfigModel?.panelPaddingTop(context);
          }
          initHeight = collapsedHeight;
        }
        if (state.dMapConfigModel?.panelDraggable == true) {
          draggable = true;
        }
        if (state.dMapConfigModel?.panelAnchorHeight != null) {
          anchorHeight = state.dMapConfigModel?.panelAnchorHeight(context);
        }
        if (state.dMapConfigModel?.panelCollapsedHeight != null) {
          collapsedHeight = state.dMapConfigModel?.panelCollapsedHeight(context);
          initHeight = collapsedHeight;
        }

        double panelMax = (maxHeight - topPadding) / maxHeight;
        double panelMin = collapsedHeight / maxHeight;
        double panelAnchor = anchorHeight / maxHeight;
        double panelInitSize = initHeight / maxHeight;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myWidget.DraggableScrollableActuator.reset(poiDraggablePanelKey.currentContext);
        });

        //---------------------------
        //set opt bar
        //---------------------------
        bool showOptBar = false;
        if (state is ShowPoiState) {
          showOptBar = true;
        }

        //---------------------------
        // dMap
        //---------------------------
        List<HeavenDataModel> heavenModelList = state.dMapConfigModel?.heavenDataModelList;
        OnMapClickHandle onMapClickHandle;
        OnMapLongPressHandle onMapLongPressHandle;
        onMapClickHandle = state.dMapConfigModel?.onMapClickHandle;
        onMapLongPressHandle = state.dMapConfigModel?.onMapLongPressHandle;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
//            Container(), //need a container to expand the stack???
            MapContainer(
              key: Keys.mapContainerKey,
              heavenDataList: heavenModelList,
//              bottomPanelController: widget.poiBottomSheetController,
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
            myWidget.DraggableScrollableActuator(
              child: NotificationListener<HeaderHeightNotification>(
                onNotification: (notification) {
                  //hack, not elegant
                  var draggableSheet = poiDraggablePanelKey.currentWidget as myWidget.DraggableScrollableSheet;
                  draggableSheet.initialChildSize = notification.height / maxHeight;
                  draggableSheet.minChildSize = notification.height / maxHeight;
                  myWidget.DraggableScrollableActuator.reset(poiDraggablePanelKey.currentContext);
                  return true;
                },
                child: NotificationListener<myWidget.DraggableScrollableNotification>(
                  onNotification: (notification) {
                    if (notification.extent <= notification.anchorExtent) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        (Keys.mapContainerKey.currentState as MapContainerState)
                            .onDragPanelYChange(notification.extent);
                      });
                    }
                    return false;
                  },
                  child: myWidget.DraggableScrollableSheet(
                    key: poiDraggablePanelKey,
                    maxChildSize: panelMax,
                    anchorSize: panelAnchor,
                    minChildSize: panelMin,
                    initialChildSize: panelInitSize,
                    draggable: draggable,
                    expand: true,
                    builder: (BuildContext ctx, ScrollController scrollController) {
                      var panel;
                      if (panelBuilder != null) {
                        panel = panelBuilder(ctx, scrollController) ??
                            SingleChildScrollView(
                              controller: scrollController,
                              child: Container(),
                            );
                      }
                      return panel ??
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Container(),
                          );
                    },
                  ),
                ),
              ),
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
