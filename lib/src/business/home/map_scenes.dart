import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

class MapScenes extends StatefulWidget {
  final DraggableBottomSheetController draggableBottomSheetController;

  MapScenes(this.draggableBottomSheetController);

  @override
  State<StatefulWidget> createState() {
    return _MapScenesState();
  }
}

class _MapScenesState extends State<MapScenes> {
  final LatLng _center = const LatLng(23.122592, 113.327356);
  final String _style = 'https://static.hyn.space/maptiles/see-it-all.json';
  final double _defaultZoom = 9.0;

  _onMapCreated(MapboxMapController controller) {
  }

  _onMapClick(Point<double> point, LatLng coordinates) {
    widget.draggableBottomSheetController.setSheetState(DraggableBottomSheetState.HIDDEN);
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      onMapClick: _onMapClick,
      styleString: _style,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: _defaultZoom,
      ),
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
    );
  }
}
