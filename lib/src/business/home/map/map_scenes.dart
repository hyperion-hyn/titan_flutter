import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/home/bloc/bloc.dart' as home;
import 'package:titan/src/business/home/searchbar/bloc/bloc.dart' as searchBar;
import 'package:titan/src/business/home/sheets/bloc/bloc.dart' as sheets;
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../../global.dart';
import 'bloc/bloc.dart';
import 'map_route.dart';

const kDoubleClickGap = 300;
const kLocationZoom = 16.0;

class MapScenes extends StatefulWidget {
  final DraggableBottomSheetController draggableBottomSheetController;

  MapScenes({this.draggableBottomSheetController});

  @override
  State<StatefulWidget> createState() {
    return _MapScenesState();
  }
}

class _MapScenesState extends State<MapScenes> {
  final LatLng _center = const LatLng(23.122592, 113.327356);
  final String _style = 'https://static.hyn.space/maptiles/see-it-all.json';
  final double _defaultZoom = 9.0;

  Symbol showingSymbol;
  IPoi currentPoi;

  int _clickTimes = 0;

  var myLocationTrackingMode = MyLocationTrackingMode.None;

  StreamSubscription _locationClickSubscription;
  StreamSubscription _eventBusSubscription;

  MapboxMapController mapboxMapController;

  _onMapClick(Point<double> point, LatLng coordinates) async {
    print('xx on click $point, $coordinates');

//    widget.draggableBottomSheetController.setSheetState(DraggableBottomSheetState.HIDDEN);

//    if(!(widget.homeBloc.currentState is HomeSearchState)) {
//      widget.homeBloc.dispatch(ClosePoiBottomSheetEvent());
//    }

//    "name != NIL"
    print("start map click event");
    var range = 10;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
    String filter;
    if (Platform.isAndroid) {
      filter = '["has", "name"]';
    }
    if (Platform.isIOS) {
      filter = "name != NIL";
    }
    List features = await mapboxMapController?.queryRenderedFeaturesInRect(rect, [], filter);

    print(features);
//    if (features != null && features.length > 0) {
//      var clickFeatureJsonString = features[0];
//      var clickFeatureJson = json.decode(clickFeatureJsonString);
//      widget.homeBloc.dispatch(SelectedPoiEvent(poiEntity: _featureToPoiEntity(clickFeatureJson)));
//    } else {
//      widget.homeBloc.dispatch(ClosePoiBottomSheetEvent());
//    }

    //TODO 瓦片中找到当前位置poi，把name补到poi里面。
    BlocProvider.of<home.HomeBloc>(context).dispatch(home.SearchPoiEvent(poi: PoiEntity(latLng: coordinates)));

  }

  _onMapLongPress(Point<double> point, LatLng coordinates) async {
    print('xx on long press $point, $coordinates');
  }

  void onStyleLoaded(controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    _toMyLocation();
  }

  void _addMarker(IPoi poi) async {
    bool shouldNeedAddSymbol = true;

    if (currentPoi != null) {
      if (currentPoi.latLng != poi.latLng) {
        _removeMarker();
      } else {
        shouldNeedAddSymbol = false;
      }
    }

    if (shouldNeedAddSymbol) {
      showingSymbol = await mapboxMapController?.addSymbol(
        SymbolOptions(
          geometry: poi.latLng,
          iconImage: "marker_big",
          iconAnchor: "bottom",
          iconOffset: Offset(0.0, 0.0),
        ),
      );

      double top = -widget.draggableBottomSheetController?.collapsedHeight;
      if (widget.draggableBottomSheetController?.getSheetState() == DraggableBottomSheetState.ANCHOR_POINT) {
        top = -widget.draggableBottomSheetController?.anchorHeight;
      }
      var offset = 0.001;
      var sw = LatLng(poi.latLng.latitude - offset, poi.latLng.longitude - offset);
      var ne = LatLng(poi.latLng.latitude + offset, poi.latLng.longitude + offset);
      mapboxMapController
          ?.animateCamera(CameraUpdate.newLatLngBounds2(LatLngBounds(southwest: sw, northeast: ne), 0, top + 32, 0, 0));

      currentPoi = poi;
    }
  }

  void _removeMarker() {
    if (showingSymbol != null) {
      mapboxMapController?.removeSymbol(showingSymbol);
    }
    showingSymbol = null;
    currentPoi = null;
  }

  var MAX_POI_DIFF_DISTANCE = 5000;

  void _addMarkers(List<IPoi> pois) {
    _clearAllMarkers();

    List<SymbolOptions> options = pois
        .map(
          (poi) => SymbolOptions(
              geometry: poi.latLng,
              iconImage: "marker_gray",
              iconAnchor: "center",
              iconSize: Platform.isAndroid ? 1 : 0.4),
        )
        .toList();
    mapboxMapController?.addSymbolList(options);

    //计算太远的距离
    var firstPoi = pois[0];
    var distanceFilterList = List<IPoi>();
    distanceFilterList.add(firstPoi);

    for (var i = 0; i < pois.length; i++) {
      var poiTemp = pois[i];
      if (firstPoi.latLng.distanceTo(poiTemp.latLng) < MAX_POI_DIFF_DISTANCE &&
          firstPoi.latLng.distanceTo(poiTemp.latLng) > 10) {
        distanceFilterList.add(poiTemp);
      }
    }

    //针对过滤后的结果，看选择不同的移动方式

    //TODO 针对地图的偏移，绑定在列表的显示和隐藏事件中

    if (distanceFilterList.length == 1) {
      mapboxMapController.animateCamera(CameraUpdate.newLatLngZoom(firstPoi.latLng, 15.0)).then((_) {
        var screenHeight = MediaQuery.of(context).size.height;
        mapboxMapController.animateCamera(CameraUpdate.scrollBy(0, -screenHeight / 4));
      });
    } else {
      var latlngList = List<LatLng>();

      for (var poi in distanceFilterList) {
        latlngList.add(poi.latLng);
      }

      var padding = 0.0;
      if (distanceFilterList.length < 5) {
        padding = 300.0;
      } else {
        padding = 150.0;
      }

      var latlngBound = LatLngBounds.fromLatLngs(latlngList);

      var screenHeight = MediaQuery.of(context).size.height;
      mapboxMapController.moveCamera(
          CameraUpdate.newLatLngBounds2(latlngBound, padding, padding, padding, screenHeight / 2 + padding));
    }
  }

  void _clearAllMarkers() {
    mapboxMapController?.clearSymbols();
    showingSymbol = null;
    currentPoi = null;
  }

  void _toMyLocation() {
    _locationClickSubscription?.cancel();
    _locationClickSubscription = null;

    _clickTimes++;
    _locationClickSubscription = Observable.timer('', Duration(milliseconds: kDoubleClickGap)).listen((value) async {
      var latLng = await mapboxMapController?.lastKnownLocation();
      if (_clickTimes > 1) {
        // double click
        if (latLng != null) {
          mapboxMapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, kLocationZoom));
        } else {
          mapboxMapController?.animateCamera(CameraUpdate.zoomTo(kLocationZoom));
        }
      } else {
        if (latLng != null) {
          mapboxMapController?.animateCamera(CameraUpdate.newLatLng(latLng));
        }
      }
      mapboxMapController?.enableLocation();
      _clickTimes = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _listenEventBus();
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      if (event is home.RouteClickEvent) {
        var toPoi = event.toPoi ?? currentPoi;
        if (toPoi != null && mapboxMapController != null) {
          LatLng start = await mapboxMapController.lastKnownLocation();
          if (start == null) {
            Fluttertoast.showToast(msg: '获取不到你当前位置');
            return;
          }

          BlocProvider.of<sheets.SheetsBloc>(context).dispatch(sheets.CloseSheetEvent());

          LatLng end = toPoi.latLng;
          String lang = Localizations.localeOf(context).languageCode;
          BlocProvider.of<MapBloc>(context).dispatch(QueryRouteEvent(
            start: start,
            end: end,
            languageCode: lang,
            startName: S.of(context).my_position,
            endName: (toPoi is PoiEntity) ? toPoi.name : '',
            selectedPoi: toPoi,
            profile: event.profile,
            padding: 150,
          ));

          BlocProvider.of<searchBar.SearchbarBloc>(context).dispatch(searchBar.HideSearchBarEvent());
        }
      } else if (event is MyLocationEvent) {
        _toMyLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MarkerLoadedState) {
          mapboxMapController?.disableLocation();
          _addMarker(state.poi);
        } else if (state is ClearMarkerState) {
          _removeMarker();
        } else if (state is MarkerListLoadedState) {
          mapboxMapController?.disableLocation();
          _addMarkers(state.pois);
        } else if (state is ClearMarkerListState) {
          _clearAllMarkers();
        } else if (state is RouteSceneState) {
          mapboxMapController?.disableLocation();
          if (!state.isLoading) {
            _clearAllMarkers();
          }
        }
      },
      child: MapboxMapParent(
        controller: mapboxMapController,
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return MapboxMap(
              onMapClick: _onMapClick,
              onMapLongPress: _onMapLongPress,
              styleString: _style,
              onStyleLoaded: onStyleLoaded,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: _defaultZoom,
              ),
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: false,
              enableLogo: false,
              enableAttribution: false,
              compassMargins: CompassMargins(left: 0, top: 88, right: 16, bottom: 0),
              minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.None,
              children: <Widget>[
//            MapRoute(),
                MapRoute(),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
    super.dispose();
  }
}
