import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/utils/utils.dart';

class SharePoisPanel extends StatefulWidget {
  final ScrollController scrollController;

  SharePoisPanel({this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return SharePoisPanelState();
  }
}

class SharePoisPanelState extends BaseState<SharePoisPanel> {
  LatLng _lastPosition;

  @override
  void onCreated() {
    super.onCreated();

    mapController?.addListener(mapListener);
  }

  void mapListener() {
    if (mapController?.isCameraMoving == false) {
      var position = mapController?.cameraPosition?.target;
      if (position != null && position != _lastPosition) {
        _lastPosition = position;
        debounce(() {
          print('位置更新了, $_lastPosition');
        }, 500)();
      }
    }
  }

  @override
  void dispose() {
    print('pane dispose');
    mapController?.removeListener(mapListener);
    super.dispose();
  }

  MapboxMapController get mapController {
    return (Keys.mapKey.currentState as MapContainerState)?.mapboxMapController;
  }

  @override
  Widget build(BuildContext context) {
    return Text('okok');
  }
}
