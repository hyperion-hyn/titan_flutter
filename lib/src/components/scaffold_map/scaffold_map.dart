import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/scaffold_map/bottom_panels/gaode_poi_panel.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/entity/poi/photo_simple_poi.dart';
import 'package:titan/src/data/entity/poi/mapbox_poi.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
import 'package:titan/src/data/entity/poi/search_history_aware_poi.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/search/search_page.dart';
import 'package:titan/src/widget/header_height_notification.dart';

import '../../widget/draggable_scrollable_sheet.dart' as myWidget;
import 'bloc/bloc.dart';
import 'bottom_panels/common_panel.dart';
import 'bottom_panels/simple_poi_panel.dart';
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
//  final GlobalKey poiDraggablePanelKey = GlobalKey(debugLabel: 'poiDraggablePanelKey');

//  ScaffoldMapStore _store = ScaffoldMapStore();

  StreamSubscription _eventbusSubscription;

  double topBarHeight = 0;

  List<ScaffoldMapState> _stateStack = [];

  @override
  void initState() {
    super.initState();
    _eventbusSubscription = Application.eventBus.on().listen(eventBusListener);
  }

  void eventBusListener(event) async {
    if (event is GoSearchEvent) {
      var mapSceneState = Keys.mapContainerKey.currentState as MapContainerState;
      var cameraPosition = await mapSceneState.mapboxMapController.getCameraPosition();
      var center = cameraPosition.target;

      var searchResult = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchPage(
                    searchCenter: center,
                    searchText: event.searchText,
                  )));

      BlocProvider.of<ScaffoldMapBloc>(context).add(DefaultMapEvent());

      if (searchResult is String) {
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchTextEvent(searchText: searchResult, center: center));
      } else if (searchResult is MapBoxPoi || searchResult is UserContributionPoi) {
        var poi = searchResult;
        if ((searchResult as SearchHistoryAwarePoi).isHistory == true) {
          BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
        } else {
          //we need to full fil all properties
          BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: poi));
        }
      }
    } else if (event is ClearSelectedPoiEvent) {
      existPoiState();
    }
  }

  @override
  void dispose() {
    _eventbusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScaffoldMapBloc, ScaffoldMapState>(listener: (context, state) {
      //back to previous state
      while (_stateStack.contains(state)) {
        _stateStack.removeLast();
      }

      //set as root state
      if (state is DefaultScaffoldMapState) {
        _stateStack.clear();
      }

      //come to a new can stack state, clear all states except
      if (state is FocusingSearchState || state is FocusingDMapState) {
        if (_stateStack.length > 0) {
          var firstState = _stateStack.first;
          _stateStack.clear();
          //add back default_state as root
          if (firstState is DefaultScaffoldMapState) {
            _stateStack.add(firstState);
          }
        }
      }

      //remove last if the same state type
      if (_stateStack.length > 0) {
        if (_stateStack.last != null && _stateStack.last.runtimeType == state.runtimeType) {
          _stateStack.removeLast();
        }
      }

      _stateStack.add(state);
    }, child: BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(
      builder: (context, state) {
        return buildMapByState(state);
      },
    ));
  }

  Widget buildMapByState(ScaffoldMapState state) {
    //scenes:
    //1. map
    //2. top navigation bar
    //3. search bar
    //4. route bar
    //5. bottom sheet
    //6. bottom operation bar
    //logic:  use prop to update each scene. scene use bloc to update data/state.
    return LayoutBuilder(builder: (ctx, BoxConstraints boxConstraints) {
      var languageCode = Localizations.localeOf(context).languageCode;
      double maxHeight = boxConstraints.biggest.height;

      //---------------------------
      //set map
      //---------------------------
      String style;
      if (SettingInheritedModel.of(context).areaModel.isChinaMainland) {
        style = Const.kWhiteMapStyleCn;
      } else {
        style = Const.kWhiteMapStyle;
      }

      //---------------------------
      //set topbar
      //---------------------------
      bool showTopBar = false;
      VoidCallback onTopBarBack;
      VoidCallback onTopBarClose;
      String title = '';
      if (state is FocusingSearchState) {
        showTopBar = true;
        title = state.searchText;
        onTopBarClose = () {
          BlocProvider.of<ScaffoldMapBloc>(context).add(DefaultMapEvent());
        };
        onTopBarBack = () {
          //back to previous state
          backToPreviewState();
        };
      }

      //---------------------------
      //set search bar
      //---------------------------
      String searchText = '';
      bool showSearchBar = false;
      if (state is FocusingSearchState) {
        showSearchBar = true;
        searchText = state.searchText;
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
      if (state is FocusingRouteState) {
        showRoute = true;
        fromPoi = state.fromPoi;
        toPoi = state.toPoi;
        profile = state.profile;
        language = state.language;
        routeDataModel = state.routeDataModel;
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

      if (state is DefaultScaffoldMapState) {
        //nothing
      } else if (state is FocusingPoiState) {
        //search POI detail
        if (state.status == Status.loading) {
          panelBuilder = (context, controller) => LoadingPanel(scrollController: controller);
        } else if (state.status == Status.success) {
          draggable = true;

          //check is dmap poi
          if (state.poi is IDMapPoi) {
            for (var st in _stateStack) {
              if (st is FocusingDMapState) {
                if (st.dMapConfigModel?.panelBuilder != null) {
                  panelBuilder =
                      (context, controller) => st.dMapConfigModel.panelBuilder(context, controller, state.poi);

                  if (st.dMapConfigModel?.panelPaddingTop != null) {
                    topPadding = st.dMapConfigModel?.panelPaddingTop(context);
                  }
                }
                break;
              }
            }
          }

          if (panelBuilder == null) {
            if (state.poi is MapBoxPoi) {
              panelBuilder = (context, controller) => SimplePoiPanel(
                    scrollController: controller,
                    selectedPoiEntity: state.poi,
                    onClose: existPoiState,
                  );
            } else if (state.poi is SimplePoiWithPhoto) {
              panelBuilder = (context, controller) => GaodePoiPanel(
                    scrollController: controller,
                    poi: state.poi,
                    onClose: existPoiState,
                  );
            } else if (state.poi is UserContributionPoi) {
              panelBuilder = (context, controller) => UserPoiPanel(
                    scrollController: controller,
                    selectedPoiEntity: state.poi,
                    onClose: existPoiState,
                  );
            }
          }
        } else if (state.status == Status.failed) {
          panelBuilder = (context, controller) => FailPanel(
                scrollController: controller,
                message: state.message,
                onClose: existPoiState,
              );
        }
        initHeight = collapsedHeight;
      } else if (state is FocusingSearchState) {
        if (state.status == Status.failed) {
          panelBuilder = (context, controller) => FailPanel(
                message: state.message,
                showCloseBtn: true,
                scrollController: controller,
                onClose: existSearchState,
              );

          initHeight = collapsedHeight;
        } else if (state.status == Status.loading) {
          panelBuilder = (context, controller) => LoadingPanel(scrollController: controller);
          initHeight = collapsedHeight;
        } else if (state.status == Status.success) {
          draggable = true;
          topPadding = topBarHeight + 12; //minus "drag" height 12

          panelBuilder = (context, controller) => SearchListPanel(
                scrollController: controller,
                pois: state.pois,
                onClose: existSearchState,
                onTapPoi: onShowDetailOfSearchItem,
              );

          if (state.pois != null && state.pois.length > 0) {
            initHeight = anchorHeight;
          } else {
            initHeight = collapsedHeight;
          }
        }
      } else if (state is FocusingRouteState) {
        //route on progress
        if (state.status == Status.loading) {
          panelBuilder = (context, controller) => LoadingPanel(
                scrollController: controller,
              );
          initHeight = collapsedHeight;
        } else if (state.status == Status.failed) {
          panelBuilder = (context, controller) => FailPanel(
                message: state.message,
                showCloseBtn: false,
                scrollController: controller,
                onClose: existRouteState,
              );
          initHeight = collapsedHeight;
        } else if (state.status == Status.success) {
          panelBuilder = (context, controller) => RoutePanel(
                routeDataModel: routeDataModel,
                profile: profile,
                scrollController: controller,
              );
          initHeight = collapsedHeight;
        }
      }

      //---------------------------
      //set opt bar
      //---------------------------
      bool showOptBar = false;
      IPoi currentPoi;
      if (state is FocusingPoiState) {
        currentPoi = state.poi;
        if (state.status == Status.success) {
          showOptBar = true;
        }
      }

      //---------------------------
      // dMap
      //---------------------------
      List<HeavenDataModel> heavenModelList;
      OnMapClickHandle onMapClickHandle;
      OnMapLongPressHandle onMapLongPressHandle;
      bool showCenterMarker = false;
      if (state is FocusingDMapState) {
        heavenModelList = state.dMapConfigModel?.heavenDataModelList;
        onMapClickHandle = state.dMapConfigModel?.onMapClickHandle;
        onMapLongPressHandle = state.dMapConfigModel?.onMapLongPressHandle;
        showCenterMarker = state.dMapConfigModel?.showCenterMarker == true;

        print('[scaffold_map] ---> dmap, begin...${state.dMapConfigModel.dMapName}');

        if (state.dMapConfigModel?.panelDraggable == true) {
          draggable = true;
          print('[scaffold_map] ---> dmap, draggable:${draggable}');
        }

        if (state.dMapConfigModel?.panelAnchorHeight != null) {
          anchorHeight = state.dMapConfigModel?.panelAnchorHeight(context);
          print('[scaffold_map] ---> dmap, anchorHeight:${anchorHeight}');
        }

        if (state.dMapConfigModel?.panelCollapsedHeight != null) {
          collapsedHeight = state.dMapConfigModel?.panelCollapsedHeight(context);
          initHeight = collapsedHeight;
          print('[scaffold_map] ---> dmap, collapsedHeight:${collapsedHeight}, initHeight:${initHeight}');
        }

        //for dMap, always show sheet panel, for now mainly for share Encrypted location Share
        print('[scaffold_map] ---> dmap, panelBuilder:${panelBuilder}');

        if (panelBuilder == null &&
            state.dMapConfigModel?.alwaysShowPanel == true &&
            state.dMapConfigModel?.panelBuilder != null) {
          panelBuilder = (context, controller) => state.dMapConfigModel.panelBuilder(context, controller, null);
          if (state.dMapConfigModel?.panelPaddingTop != null) {
            topPadding = state.dMapConfigModel?.panelPaddingTop(context);
            print('[scaffold_map] ---> dmap-Encrypted, topPadding:${topPadding}');
          }
          initHeight = collapsedHeight;
          print('[scaffold_map] ---> dmap-Encrypted, initHeight:${initHeight}');
        }
      }

      double panelMax = (maxHeight - topPadding) / maxHeight;
      double panelMin = collapsedHeight / maxHeight;
      double panelAnchor = anchorHeight / maxHeight;
      double panelInitSize = initHeight / maxHeight;
      if (panelBuilder != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myWidget.DraggableScrollableActuator.reset(Keys.mapDraggablePanelKey.currentContext);
        });
      }else{
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myWidget.DraggableScrollableActuator.setHide(Keys.mapDraggablePanelKey.currentContext);
        });
      }

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
              onBack: existRouteState,
              onReRoute: (String toProfile) {
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
                var draggableSheet = Keys.mapDraggablePanelKey.currentWidget as myWidget.DraggableScrollableSheet;
                draggableSheet.initialChildSize = notification.height / maxHeight;
                draggableSheet.minChildSize = notification.height / maxHeight;
                myWidget.DraggableScrollableActuator.reset(Keys.mapDraggablePanelKey.currentContext);
                return true;
              },
              child: NotificationListener<myWidget.DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent <= notification.anchorExtent) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      (Keys.mapContainerKey.currentState as MapContainerState).onDragPanelYChange(notification.extent);
                    });
                  }
                  return false;
                },
                child: myWidget.DraggableScrollableSheet(
                  key: Keys.mapDraggablePanelKey,
                  maxHeight: maxHeight,
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
                onRouteTap: () => enterRoute(currentPoi),
              ),
            ),
        ],
      );
    });
  }

  void existPoiState() {
    backToPreviewState();
//    for (var state in _stateStack) {
//      if (state is FocusingSearchState || state is FocusingDMapState) {
//        //back to pre state
//        backToPreviewState();
//        return;
//      }
//    }
//    //no stack, just back to default
//    getBloc()?.add(DefaultMapEvent());
  }

  ScaffoldMapBloc getBloc() {
    return BlocProvider.of<ScaffoldMapBloc>(context);
  }

  void existRouteState() {
    //back to pre state
    backToPreviewState();
  }

  void existSearchState() {
    //back to default
    backToPreviewState();
  }

  void backToPreviewState() {
    if (_stateStack.length > 1) {
      getBloc()?.add(YieldStateEvent(state: _stateStack[_stateStack.length - 2]));
    } else {
      getBloc()?.add(DefaultMapEvent());
    }
  }

  void onShowDetailOfSearchItem(IPoi poi) {
    getBloc()?.add(ShowPoiEvent(poi: poi));
  }

  void enterRoute(IPoi poi) async {
    var currentPoi = poi;
    if (currentPoi != null) {
      var location = await getMapState?.mapboxMapController?.lastKnownLocation();
      if (location == null) {
        Fluttertoast.showToast(msg: S.of(context).cannot_get_your_location);
      } else {
        var fromPoi = MapBoxPoi(latLng: location, name: S.of(context).my_location);
        var toPoi = currentPoi;
        var language = Localizations.localeOf(context).languageCode;
        var defaultProfile = RouteProfile.driving;
        BlocProvider.of<ScaffoldMapBloc>(context).add(RouteEvent(
          fromPoi: fromPoi,
          toPoi: toPoi,
          language: language,
          profile: defaultProfile,
        ));
      }
    }
  }

  MapContainerState get getMapState {
    return Keys.mapContainerKey.currentState as MapContainerState;
  }
}
