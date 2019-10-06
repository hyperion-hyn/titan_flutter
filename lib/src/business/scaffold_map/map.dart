import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../global.dart';
import 'bloc/bloc.dart';

class MapContainer extends StatefulWidget {
  final List<HeavenDataModel> heavenDataList;
  final RouteDataModel routeDataModel;
  final String style;
  final double defaultZoom;
  final LatLng defaultCenter;

  final DraggableBottomSheetController bottomPanelController;

  MapContainer({
    Key key,
    this.heavenDataList,
    this.routeDataModel,
    this.style,
    this.defaultZoom = 9.0,
    this.defaultCenter = const LatLng(23.122592, 113.327356),
    this.bottomPanelController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapContainerState();
  }
}

class MapContainerState extends State<MapContainer> {
  MapboxMapController mapboxMapController;

  Symbol showingSymbol;
  IPoi currentPoi;

  Map<String, IPoi> _currentGrayMarkerMap = Map();
  List<String> heavenMapLayers = [];

  @override
  void initState() {
    super.initState();
    widget.bottomPanelController?.addListener(onDragPanelYChange);
  }

  double _mapTop = 0;

  void onDragPanelYChange() {
    if (widget.bottomPanelController.bottom <= widget.bottomPanelController.anchorHeight &&
        widget.bottomPanelController.bottom > widget.bottomPanelController.collapsedHeight) {
      setState(() {
        _mapTop = -widget.bottomPanelController.bottom * 0.5;
      });
    }
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    var range = 10;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
    if (await _clickOnMarkerLayer(rect)) {
      return;
    }
    if (await _clickOnHeavenLayer(rect)) {
      return;
    }
    if (await _clickOnCommonSymbolLayer(rect)) {
      return;
    }
    //if click nothing on the map
    if (this.currentPoi != null) {
      BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ClearSelectPoiEvent());
    }

//    //clear selected poi
//    var homeBloc = BlocProvider.of<home.HomeBloc>(context);
//    if (homeBloc.searchText != null) {
//      homeBloc.dispatch(home.SearchTextEvent(searchText: homeBloc.searchText));
//    } else {
//      homeBloc.dispatch(home.ExistSearchEvent());
//    }
  }

  _onMapLongPress(Point<double> point, LatLng coordinates) async {
    var range = 10;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);

    if (await _clickOnMarkerLayer(rect)) {
      return;
    }
    if (await _clickOnHeavenLayer(rect)) {
      return;
    }
    if (await _clickOnCommonSymbolLayer(rect)) {
      return;
    }

    //if click on no symbol, then add the place where it is
    var poi = PoiEntity(latLng: coordinates);
    BlocProvider.of<ScaffoldMapBloc>(context).dispatch(SearchPoiEvent(poi: poi));
  }

  void _addMarker(IPoi poi) async {
    bool shouldNeedAddSymbol = true;

    if (currentPoi != null) {
      if (currentPoi.latLng != poi.latLng) {
        //位置不同，先删除再添加新的Marker
        _removeMarker();
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

//      double top = -widget.draggableBottomSheetController?.collapsedHeight;
//      if (widget.draggableBottomSheetController?.getSheetState() == DraggableBottomSheetState.ANCHOR_POINT) {
//        top = -widget.draggableBottomSheetController?.anchorHeight;
//      }
//      print("top:$top");
//      var offset = 0.0002;
//      var sw = LatLng(poi.latLng.latitude - offset, poi.latLng.longitude - offset);
//      var ne = LatLng(poi.latLng.latitude + offset, poi.latLng.longitude + offset);
//      mapboxMapController?.animateCamera(
//          CameraUpdate.newLatLngBounds2(LatLngBounds(southwest: sw, northeast: ne), 10, top + 42, 10, 10));
      mapboxMapController?.animateCamera(CameraUpdate.newLatLngZoom(poi.latLng, 16));

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
        BlocProvider.of<ScaffoldMapBloc>(context).dispatch(SearchPoiEvent(poi: poi));
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
      BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ShowPoiEvent(poi: poi));
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

      var poi = PoiEntity(name: name, latLng: coordinates);
      BlocProvider.of<ScaffoldMapBloc>(context).dispatch(SearchPoiEvent(poi: poi));

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

  void onStyleLoaded(controller) async {
    setState(() {
      mapboxMapController = controller;
    });

//    _toMyLocation();
//    _loadPurchasedMap();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
      listener: (context, state) {
        if (state is SearchingPoiState || state is ShowPoiState) {
          _addMarker(state.getCurrentPoi());
        } else if (state is InitialScaffoldMapState) {
          _removeMarker();
          setState(() {
            _mapTop = 0;
          });
        }
      },
      child: Positioned(
        top: _mapTop,
        child: Container(
          height: MediaQuery.of(context).size.height + bottomBarHeight,
          width: MediaQuery.of(context).size.width,
          child: MapboxMapParent(
              controller: mapboxMapController,
              child: MapboxMap(
                onMapClick: _onMapClick,
                onMapLongPress: _onMapLongPress,
                styleString: widget.style,
                onStyleLoaded: onStyleLoaded,
                initialCameraPosition: CameraPosition(
                  target: widget.defaultCenter,
                  zoom: widget.defaultZoom,
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
                  ///active plugins
                  HeavenPlugin(models: widget.heavenDataList),
                  RoutePlugin(model: widget.routeDataModel),
                ],
              )),
        ),
      ),
    );
  }
}
