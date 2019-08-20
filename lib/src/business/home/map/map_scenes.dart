import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
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

  MapScenes({this.draggableBottomSheetController, key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapScenesState();
  }
}

class MapScenesState extends State<MapScenes> {
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
    var range = 10;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);

    if (await _clickOnMarkerLayer(rect)) {
      return;
    }
    if (await _clickOnCommonSymbolLayer(rect)) {
      return;
    }

    //clear selected poi
    var homeBloc = BlocProvider.of<home.HomeBloc>(context);
    if (homeBloc.searchText != null) {
      homeBloc.dispatch(home.SearchTextEvent(searchText: homeBloc.searchText));
    } else {
      homeBloc.dispatch(home.ExistSearchEvent());
    }
  }

  Future<bool> _clickOnCommonSymbolLayer(Rect rect) async {
    String filter;
    if (Platform.isAndroid) {
      filter = '["has", "name"]';
    }
    if (Platform.isIOS) {
      filter = "name != NIL";
    }
    List features = await mapboxMapController?.queryRenderedFeaturesInRect(rect, [], filter);

    print("query features :${features}");
    var filterFeatureList = features.where((featureString) {
      var feature = json.decode(featureString);

      var type = feature["geometry"]["type"];
      if (type == "Point") {
        return true;
      } else {
        return false;
      }
    }).toList();

    print("filter features :${filterFeatureList}");
    if (filterFeatureList != null && filterFeatureList.isNotEmpty) {
      var firstFeature = json.decode(filterFeatureList[0]);
      var coordinatesArray = firstFeature["geometry"]["coordinates"];
      var coordinates = LatLng(coordinatesArray[1], coordinatesArray[0]);
      print("coordinates:${coordinates}");
      var languageCode = Localizations.localeOf(context).languageCode;
      var name = "";
      if (languageCode == "zh") {
        name = firstFeature["properties"]["name:zh"];
        if (name == null) {
          name = firstFeature["properties"]["name"];
        }
      } else {
        name = firstFeature["properties"]["name"];
      }

      BlocProvider.of<home.HomeBloc>(context)
          .dispatch(home.SearchPoiEvent(poi: PoiEntity(latLng: coordinates, name: name)));
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _clickOnMarkerLayer(Rect rect) async {
    // 查找搜索结果的layer

    String symbolMarkerLayerId = "";
    if (Platform.isIOS) {
      symbolMarkerLayerId = "hyn-batch-add-marker-layer";
    }
    if (Platform.isAndroid) {
      symbolMarkerLayerId = "mapbox-android-symbol-layer";
    }

    List symbolMarkerFeatures =
        await mapboxMapController?.queryRenderedFeaturesInRect(rect, [symbolMarkerLayerId], null);
    if (symbolMarkerFeatures != null && symbolMarkerFeatures.isNotEmpty) {
      print("symbolMarkerFeatures：" + symbolMarkerFeatures[0]);

      var symbolMarkerFeature = json.decode(symbolMarkerFeatures[0]);

      var markerId = symbolMarkerFeature["properties"]["id"].toInt();

      print("markerID:${markerId}");

      print("_currentGrayMarkerMap:${_currentGrayMarkerMap}");
      var poi = _currentGrayMarkerMap[markerId.toString()];

      print("poi:${poi}");

      var coordinates = poi.latLng;

      BlocProvider.of<home.HomeBloc>(context)
          .dispatch(home.SearchPoiEvent(poi: PoiEntity(latLng: coordinates, name: poi.name)));
      return true;
    } else {
      return false;
    }
  }

  _onMapLongPress(Point<double> point, LatLng coordinates) async {
    BlocProvider.of<home.HomeBloc>(context).dispatch(home.SearchPoiEvent(poi: PoiEntity(latLng: coordinates)));
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
          iconImage: "hyn_marker_big",
          iconAnchor: "bottom",
          iconOffset: Offset(0.0, 3.0),
        ),
      );

      double top = -widget.draggableBottomSheetController?.collapsedHeight;
      if (widget.draggableBottomSheetController?.getSheetState() == DraggableBottomSheetState.ANCHOR_POINT) {
        top = -widget.draggableBottomSheetController?.anchorHeight;
      }
      print("top:$top");
      var offset = 0.0002;
      var sw = LatLng(poi.latLng.latitude - offset, poi.latLng.longitude - offset);
      var ne = LatLng(poi.latLng.latitude + offset, poi.latLng.longitude + offset);
      mapboxMapController?.animateCamera(
          CameraUpdate.newLatLngBounds2(LatLngBounds(southwest: sw, northeast: ne), 10, top + 42, 10, 10));

      currentPoi = poi;
    }
  }

  void _resetMap() {
    mapboxMapController.disableLocation();
    mapboxMapController.moveCamera(CameraUpdate.newLatLngZoom(_center, _defaultZoom));
  }

  void _removeMarker() {
    if (showingSymbol != null) {
      mapboxMapController?.removeSymbol(showingSymbol);
    }
    showingSymbol = null;
    currentPoi = null;
  }

  var MAX_POI_DIFF_DISTANCE = 10000;

  var _currentGrayMarkerMap = Map<String, IPoi>();

  void _addMarkers(List<IPoi> pois) async {
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
    var symbolList = await mapboxMapController?.addSymbolList(options);

    for (var i = 0; i < symbolList.length; i++) {
      _currentGrayMarkerMap[symbolList[i].id] = pois[i];
    }

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
        print("screenHeight: $screenHeight");
        mapboxMapController.animateCamera(CameraUpdate.scrollBy(0, -screenHeight / 4));
      });
    } else {
      var latlngList = List<LatLng>();

      for (var poi in distanceFilterList) {
        latlngList.add(poi.latLng);
      }

      var padding = 50.0;
//      if (distanceFilterList.length < 5) {
//        padding = 200.0;
//      } else {
//        padding = 50.0;
//      }

      var latlngBound = LatLngBounds.fromLatLngs(latlngList);

      var screenHeight = MediaQuery.of(context).size.height;
      mapboxMapController.moveCamera(
          CameraUpdate.newLatLngBounds2(latlngBound, padding, padding * 1.2, padding, screenHeight / 2 + padding));
    }
  }

  void _clearAllMarkers() {
    mapboxMapController?.clearSymbols();
    showingSymbol = null;
    currentPoi = null;
    _currentGrayMarkerMap.clear();
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

  void _showGoToOpenAppSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text('申请定位授权'),
                  content: Text('请你授权使用定位功能.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text('申请定位授权'),
                  content: Text('请你授权使用定位功能.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
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
            padding: 450,
          ));

          BlocProvider.of<searchBar.SearchbarBloc>(context).dispatch(searchBar.HideSearchBarEvent());
        }
      } else if (event is MyLocationEvent) {
        PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
        if (permission == PermissionStatus.granted) {
          _toMyLocation();
        } else {
          Map<PermissionGroup, PermissionStatus> permissions =
              await PermissionHandler().requestPermissions([PermissionGroup.location]);
          if (permissions[PermissionGroup.location] == PermissionStatus.granted) {
            _toMyLocation();
            Observable.timer('', Duration(milliseconds: 1500)).listen((d) {
              _toMyLocation(); //hack, location not auto move
            });
          } else {
//              Fluttertoast.showToast(msg: "Failed to get location permissions");
            _showGoToOpenAppSettingsDialog();
          }
        }
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
        } else if (state is ResetMapState) {
          _resetMap();
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
