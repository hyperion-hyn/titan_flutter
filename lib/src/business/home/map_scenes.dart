import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../global.dart';
import 'bloc/bloc.dart';

class MapScenes extends StatefulWidget {
  final HomeBloc homeBloc;
  final String language;

  MapScenes({this.homeBloc, this.language});

  @override
  State<StatefulWidget> createState() {
    return _MapScenesState();
  }
}

class _MapScenesState extends State<MapScenes> {
  final LatLng _center = const LatLng(23.122592, 113.327356);
  final String _style = 'https://static.hyn.space/maptiles/see-it-all.json';
  final double _defaultZoom = 9.0;

  var myLocationTrackingMode = MyLocationTrackingMode.None;

  MapboxMapController mapboxMapController;

  _onMapClick(Point<double> point, LatLng coordinates) async {
//    widget.draggableBottomSheetController.setSheetState(DraggableBottomSheetState.HIDDEN);
    if(!(widget.homeBloc.currentState is HomeSearchState)) {
      widget.homeBloc.dispatch(ClosePoiBottomSheetEvent());
    }

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

    eventBus.fire(MyLocationClickEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMapParent(
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
        compassMargins: CompassMargins(left: 0, top: Platform.isAndroid ? 88 : 72, right: 16, bottom: 0),
        minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
        myLocationEnabled: true,
        myLocationTrackingMode: MyLocationTrackingMode.None,
      ),
    );
  }
}
