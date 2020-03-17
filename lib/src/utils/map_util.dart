import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/config/consts.dart';

class MapUtil {
  static Future<Map<String, dynamic>> getFeature(Point<double> point, LatLng coordinates, String layerId,
      [MapboxMapController mapController]) async {
    var range = 20;
    Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
    var mapboxMapController =
        mapController ?? (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController;
    List features = await mapboxMapController?.queryRenderedFeaturesInRect(rect, [layerId], null);
    if (features != null && features.length > 0) {
      return json.decode(features[0]);
    }

    return null;
  }
}
