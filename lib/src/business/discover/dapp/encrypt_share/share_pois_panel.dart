import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/model/poi_interface.dart';

class SharePoisPanel extends StatefulWidget {
  final ScrollController scrollController;

  SharePoisPanel({this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return SharePoisPanelState();
  }
}

class SharePoisPanelState extends BaseState<SharePoisPanel> {
  @override
  void onCreated() {
    super.onCreated();

    mapController?.addListener(mapListener);
  }

  void mapListener() {
    print('xxx isMoving ${mapController?.isCameraMoving}');
    print('xxx position ${mapController?.cameraPosition?.target}');
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
