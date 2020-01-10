import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/position/api/position_api.dart';
import 'package:titan/src/business/position/model/confirm_poi_item.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/consts/extends_icon_font.dart';

import '../../global.dart';
import 'bloc/bloc.dart';

typedef Future<bool> OnMapClickHandle(BuildContext context, Point<double> point, LatLng coordinates);
typedef Future<bool> OnMapLongPressHandle(BuildContext context, Point<double> point, LatLng coordinates);

class MapContainer extends StatefulWidget {
  final List<HeavenDataModel> heavenDataList;
  final RouteDataModel routeDataModel;
  final String style;
  final double defaultZoom;
  final LatLng defaultCenter;
  final OnMapClickHandle mapClickHandle;
  final OnMapLongPressHandle mapLongPressHandle;
  final bool showCenterMarker;

//  final DraggableBottomSheetController bottomPanelController;
  final String languageCode;

  MapContainer(
      {Key key,
      this.heavenDataList,
      this.routeDataModel,
      this.style,
      this.defaultZoom = 9.0,
      this.defaultCenter = const LatLng(23.122592, 113.327356),
//    this.bottomPanelController,
      this.mapClickHandle,
      this.mapLongPressHandle,
      this.showCenterMarker,
      this.languageCode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapContainerState();
  }
}

class MapContainerState extends State<MapContainer> with SingleTickerProviderStateMixin {
  static const int _MAX_POI_DIFF_DISTANCE = 10000;

  MapboxMapController mapboxMapController;

  MyLocationTrackingMode locationTrackingMode = MyLocationTrackingMode.None;
  bool myLocationEnabled = true;

//  StreamSubscription _locationClickSubscription;
  PublishSubject<dynamic> _toLocationEventSubject = PublishSubject<dynamic>();

  StreamSubscription _eventBusSubscription;

  AnimationController _mapPositionAnimationController;
  final PublishSubject<double> _updateMapPositionSubject = PublishSubject<double>();

  Symbol showingSymbol;
  IPoi currentPoi;

  Map<String, IPoi> _currentGrayMarkerMap = Map();
  List<String> heavenMapLayers = [];

//  PositionApi _positionApi = PositionApi();

  @override
  void initState() {
    super.initState();
    _mapPositionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 1.0,
      vsync: this,
    );

    //to my location
    _toLocationEventSubject.debounceTime(Duration(milliseconds: 500)).listen((_) async {
      bool needUpdate = enableMyLocation(true);
      bool trackModeChange = updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
      if (needUpdate || trackModeChange) {
        await Future.delayed(Duration(milliseconds: 300));
      }

      var latLng = await mapboxMapController?.lastKnownLocation();
      double doubleClickZoom = 17;
      if (latLng != null) {
        if (_clickTimes > 1) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLngZoom(latLng, doubleClickZoom), 1200);
        } else if (!trackModeChange) {
          mapboxMapController?.animateCameraWithTime(CameraUpdate.newLatLng(latLng), 700);
        }
      }
      _clickTimes = 0;
    });
    //map padding by bottom sheet
    _updateMapPositionSubject.debounceTime(Duration(milliseconds: 50)).listen((lastValue) {
//      _mapPositionAnimationController.animateTo(lastValue, curve: Curves.linearToEaseOut);
      _mapPositionAnimationController.value = lastValue;
    });

    _listenEventBus();
  }

  void onDragPanelYChange(double value) {
    if (value != _mapPositionAnimationController.value) {
//      _mapPositionAnimationController.value = value;
      _updateMapPositionSubject.add(value);
    }
  }

  bool enableMyLocation(bool enable) {
    if (myLocationEnabled != enable) {
      setState(() {
        myLocationEnabled = enable;
      });
      return true;
    }
    return false;
  }

  bool updateMyLocationTrackingMode(MyLocationTrackingMode mode) {
    print('xxx 1 $locationTrackingMode $mode $myLocationEnabled');
    if (mode != locationTrackingMode) {
      print('xxx 2 $mode');
      setState(() {
        locationTrackingMode = mode;
      });
      return true;
    }
    return false;
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    if (widget.mapClickHandle != null) {
      if (await widget.mapClickHandle(context, point, coordinates)) {
        return;
      }
    }

    var range = 10;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
    if (await _clickOnMarkerLayer(rect)) {
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
      return;
    }
    if (await _clickOnCommonSymbolLayer(rect)) {
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
      return;
    }

    //if click nothing on the map
    if (this.currentPoi != null) {
      BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectPoiEvent());
    }
  }

  _onMapLongPress(Point<double> point, LatLng coordinates) async {
    if (widget.mapLongPressHandle != null) {
      if (await widget.mapLongPressHandle(context, point, coordinates)) {
        return;
      }
    }

    var range = 10;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);

    if (await _clickOnMarkerLayer(rect)) {
      return;
    }
    if (await _clickOnCommonSymbolLayer(rect)) {
      return;
    }

    //if click on no symbol, then add the place where it is
    var poi = PoiEntity(latLng: coordinates);
    BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: poi));
  }

  void addMarker(IPoi poi) async {
    bool shouldNeedAddSymbol = true;

    if (currentPoi != null) {
      if (currentPoi.latLng != poi.latLng) {
        //位置不同，先删除再添加新的Marker
        removeMarker();
      } else {
        //位置相同，不需要再添加Marker
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

      mapboxMapController?.animateCamera(CameraUpdate.newLatLngZoom(poi.latLng, 17));

      currentPoi = poi;
    }
  }

  void removeMarker() {
    if (showingSymbol != null) {
      mapboxMapController?.removeSymbol(showingSymbol);
    }
    showingSymbol = null;
    currentPoi = null;
  }

  void _addMarkers(List<IPoi> pois) async {
    await clearAllMarkers();

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

    //-----------------
    // pan camera
    // the first poi as center.
    //-----------------
    var firstPoi = pois[0];
    var distanceFilterList = List<IPoi>();
    distanceFilterList.add(firstPoi);
    for (var i = 0; i < pois.length; i++) {
      var poiTemp = pois[i];
      var distance = firstPoi.latLng.distanceTo(poiTemp.latLng);
      if (distance < _MAX_POI_DIFF_DISTANCE && distance > 10) {
        distanceFilterList.add(poiTemp);
      }
    }
    if (distanceFilterList.length == 1) {
      mapboxMapController.animateCamera(CameraUpdate.newLatLngZoom(firstPoi.latLng, 15.0));
    } else {
      var latlngList = List<LatLng>();
      for (var poi in distanceFilterList) {
        latlngList.add(poi.latLng);
      }
      var padding = 50.0;
      var latlngBound = LatLngBounds.fromLatLngs(latlngList);
      mapboxMapController
          .moveCamera(CameraUpdate.newLatLngBounds2(latlngBound, padding, padding * 1.2, padding, padding * 1.2));
    }
  }

  Future<void> clearAllMarkers() async {
    await mapboxMapController?.clearSymbols();
    showingSymbol = null;
    currentPoi = null;
    _currentGrayMarkerMap.clear();
  }

  /// 查找搜索结果的layer
  Future<bool> _clickOnMarkerLayer(Rect rect) async {
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

      print("markerID:$markerId");

      print("_currentGrayMarkerMap:$_currentGrayMarkerMap");
      var poi = _currentGrayMarkerMap[markerId.toString()];

      print("poi:$poi");

      if (poi != null) {
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: poi));
        return true;
      }
    }
    return false;
  }

  Future<bool> _clickOnHeavenLayer(Rect rect) async {
    // search heaven map layer
    print("heavenMapLayers:$heavenMapLayers");
    if (heavenMapLayers.isEmpty) {
      return false;
    }
    List symbolFeatures = await mapboxMapController?.queryRenderedFeaturesInRect(rect, heavenMapLayers, null);
    if (symbolFeatures != null && symbolFeatures.isNotEmpty) {
      var firstFeature = json.decode(symbolFeatures[0]);
      print("firstFeature :$firstFeature");
      var poi = _convertHeavenMapPoiInfoFromFeature(firstFeature);
      BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
      return true;
    } else {
      return false;
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

    print("query features :$features");
    var filterFeatureList = features.where((featureString) {
      var feature = json.decode(featureString);

      var type = feature["geometry"]["type"];
      if (type == "Point") {
        return true;
      } else {
        return false;
      }
    }).toList();

    print("filter features :$filterFeatureList");
    if (filterFeatureList != null && filterFeatureList.isNotEmpty) {
      var firstFeature = json.decode(filterFeatureList[0]);
      var coordinatesArray = firstFeature["geometry"]["coordinates"];
      var coordinates = LatLng(coordinatesArray[1], coordinatesArray[0]);
      print("coordinates:$coordinates");
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

      //the same poi
      if (currentPoi?.latLng == coordinates) {
        print('click the same poi');
        return true;
      }

      var pid = firstFeature["properties"]["pid"];
      //user contribute poi
      if(pid != null){
        print("has get pid");
//        var className = firstFeature["properties"]["class"];
//        var rank = firstFeature["properties"]["rank"];
//        var lat = firstFeature["properties"]["lat"];
//        var language = "zh-Hans";
//        var _confirmDataList = await _positionApi.mapGetConfirmData(pid);
        ConfirmPoiItem confirmPoiItem = ConfirmPoiItem.setPid(pid);
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: confirmPoiItem));
      }else{
        var poi = PoiEntity(name: name, latLng: coordinates);
        BlocProvider.of<ScaffoldMapBloc>(context).add(SearchPoiEvent(poi: poi));
      }



      return true;
    } else {
      return false;
    }
  }

  HeavenMapPoiInfo _convertHeavenMapPoiInfoFromFeature(Map<String, dynamic> feature) {
    HeavenMapPoiInfo heavenMapPoiInfo = HeavenMapPoiInfo();

    heavenMapPoiInfo.id = feature["id"] is int ? feature["id"].toString() : feature["id"];
    var lat = double.parse(feature["properties"]["lat"]);
    var lon = double.parse(feature["properties"]["lon"]);
    heavenMapPoiInfo.latLng = LatLng(lat, lon);
    heavenMapPoiInfo.time = feature["properties"]["time"];
    heavenMapPoiInfo.phone = feature["properties"]["telephone"];
    heavenMapPoiInfo.service = feature["properties"]["service"];
    heavenMapPoiInfo.address = feature["properties"]["address"];
    heavenMapPoiInfo.desc = feature["properties"]["desc"];
    heavenMapPoiInfo.name = feature["properties"]["name"];
    return heavenMapPoiInfo;
  }

  void onStyleLoaded(MapboxMapController controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    controller.removeListener(_mapMoveListener);
    controller.addListener(_mapMoveListener);
  }

  void _mapMoveListener() {
    //change tracking mode to none if user drag the map
    if (mapboxMapController?.isGesture == true) {
      updateMyLocationTrackingMode(MyLocationTrackingMode.None);
    }
  }

  int _clickTimes = 0;

  Future _toMyLocation() async {
    _clickTimes++;
    _toLocationEventSubject.sink.add(1);
  }

  void _listenEventBus() {
    _eventBusSubscription = eventBus.on().listen((event) async {
      if (event is ToMyLocationEvent) {
        //check location service

        ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);

        if (serviceStatus == ServiceStatus.disabled) {
          _showGoToOpenLocationServceDialog();
          return;
        }

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
            _showGoToOpenAppSettingsDialog();
          }
        }
      }
    });
  }

  void _showGoToOpenAppSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(S.of(context).require_location),
                  content: Text(S.of(context).require_location_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(S.of(context).require_location),
                  content: Text(S.of(context).require_location_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }

  void _showGoToOpenLocationServceDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(S.of(context).open_location_service),
                  content: Text(S.of(context).open_location_service_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(S.of(context).open_location_service),
                  content: Text(S.of(context).open_location_service_message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).setting),
                      onPressed: () {
                        AndroidIntent intent = new AndroidIntent(
                          action: 'action_location_source_settings',
                        );
                        intent.launch();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }

  @override
  void dispose() {
    _updateMapPositionSubject.close();
    _mapPositionAnimationController.dispose();
    mapboxMapController?.removeListener(_mapMoveListener);
//    _locationClickSubscription?.cancel();
    _toLocationEventSubject.close();
    _eventBusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
      listener: (context, state) {
        if (state is SearchingPoiState || state is ShowPoiState) {
          addMarker(state.getCurrentPoi());
        } else if (state is SearchPoiByTextSuccessState) {
          if (state.getSearchPoiList().length > 0) {
            _addMarkers(state.getSearchPoiList());
          }
        } else if (state is InitialScaffoldMapState || state is InitDMapState) {
          clearAllMarkers();
          _mapPositionAnimationController.value = 0.0;
        } else {
          removeMarker();
        }
      },
      child: BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(
        builder: (context, state) {
          return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            double minSize = 0.45 * constraints.biggest.height;
            var expandedRelative = RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0);
            var topRelative = RelativeRect.fromLTRB(0.0, -minSize, 0.0, minSize);
            final Animation<RelativeRect> panelAnimation = _mapPositionAnimationController.drive(
              RelativeRectTween(
                begin: expandedRelative,
                end: topRelative,
              ),
            );

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PositionedTransition(
                  rect: panelAnimation,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      MapboxMapParent(
                        key: Keys.mapParentKey,
                        controller: mapboxMapController,
                        child: MapboxMap(
                          compassEnabled: false,
                          onMapClick: (point, coordinates) {
                            if (state is RoutingState || state is RouteSuccessState || state is RouteFailState) {
                              return;
                            }
                            _onMapClick(point, coordinates);
                          },
                          onMapLongPress: (point, coordinates) {
                            if (state is RoutingState || state is RouteSuccessState || state is RouteFailState) {
                              return;
                            }
                            _onMapLongPress(point, coordinates);
                          },
                          trackCameraPosition: true,
                          styleString: widget.style,
                          onStyleLoaded: onStyleLoaded,
                          initialCameraPosition: CameraPosition(
                            target: widget.defaultCenter,
                            zoom: widget.defaultZoom,
                          ),
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          enableLogo: false,
                          enableAttribution: false,
                          compassMargins: CompassMargins(left: 0, top: 88, right: 16, bottom: 0),
                          minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
                          myLocationEnabled: myLocationEnabled,
                          myLocationTrackingMode: locationTrackingMode,
                          languageCode: widget.languageCode,
                          children: <Widget>[
                            ///active plugins
                            HeavenPlugin(models: widget.heavenDataList),
                            RoutePlugin(model: widget.routeDataModel),
                          ],
                        ),
                      ),
                      if (widget.showCenterMarker)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                ExtendsIconFont.position_marker,
                                size: 64,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(height: 68)
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
