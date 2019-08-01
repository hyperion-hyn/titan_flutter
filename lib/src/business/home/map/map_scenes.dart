import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc/bloc.dart';

const kDoubleClickGap = 300;
const kLocationZoom = 16.0;

class MapScenes extends StatefulWidget {
  MapScenes();

  @override
  State<StatefulWidget> createState() {
    return _MapScenesState();
  }
}

class _MapScenesState extends State<MapScenes> {
  final LatLng _center = const LatLng(23.122592, 113.327356);
  final String _style = 'https://static.hyn.space/maptiles/see-it-all.json';
  final double _defaultZoom = 9.0;

  int _clickTimes;

  var myLocationTrackingMode = MyLocationTrackingMode.None;

  StreamSubscription _locationClickSubscription;

  MapboxMapController mapboxMapController;

  _onMapClick(Point<double> point, LatLng coordinates) async {
//    widget.draggableBottomSheetController.setSheetState(DraggableBottomSheetState.HIDDEN);

//    if(!(widget.homeBloc.currentState is HomeSearchState)) {
//      widget.homeBloc.dispatch(ClosePoiBottomSheetEvent());
//    }

//    var range = 10;
//    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
//    List features = await mapboxMapController?.queryRenderedFeaturesInRect(rect, [layerId], null);
//    if (features != null && features.length > 0) {
//      var clickFeatureJsonString = features[0];
//      var clickFeatureJson = json.decode(clickFeatureJsonString);
//      widget.homeBloc.dispatch(SelectedPoiEvent(poiEntity: _featureToPoiEntity(clickFeatureJson)));
//    } else {
//      widget.homeBloc.dispatch(ClosePoiBottomSheetEvent());
//    }
  }

  void onStyleLoaded(controller) async {
    setState(() {
      mapboxMapController = controller;
    });

//    eventBus.fire(MyLocationClickEvent());
  }

  void _addMarker(LatLng coordiate) {
    //TODO
  }

  void _removeMarker() {
    //TODO
  }

  void _addRoute(dynamic routeData) {
    //TODO
  }

  void _toMyLocation() {
    _locationClickSubscription?.cancel();

    _clickTimes++;
    _locationClickSubscription =
        Observable.timer(kDoubleClickGap, Duration(milliseconds: kDoubleClickGap)).listen((time) async {
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
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MarkerLoadedState) {
          _addMarker(state.coordinate);
        } else if (state is ClearMarkerState) {
          _removeMarker();
        } else if (state is RouteLoadedState) {
          _addRoute(state.routeData);
        } else if (state is MyLocationState) {
          _toMyLocation();
        }
      },
      child: MapboxMapParent(
        controller: mapboxMapController,
        child: MapboxMap(
          onMapClick: _onMapClick,
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
        ),
      ),
    );
  }
}
