import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapScenes extends StatefulWidget {
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
    print('map created');
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
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
