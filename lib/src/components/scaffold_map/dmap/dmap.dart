import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../map.dart';
import '../scaffold_map.dart';

typedef ContextFun = double Function(BuildContext context);

class DMapConfigModel {
  final List<HeavenDataModel> heavenDataModelList;
  final String dMapName;

  final LatLng defaultLocation;
  final double defaultZoom;

  final OnMapClickHandle onMapClickHandle;
  final OnMapLongPressHandle onMapLongPressHandle;

  final PanelBuilder panelBuilder;
  final ContextFun panelPaddingTop;
  final bool panelDraggable;
  final ContextFun panelCollapsedHeight;
  final ContextFun panelAnchorHeight;
  final bool alwaysShowPanel;

  final bool showCenterMarker;

  DMapConfigModel({
    this.panelBuilder,
    this.panelPaddingTop,
    this.panelAnchorHeight,
    this.panelCollapsedHeight,
    this.panelDraggable,
    this.alwaysShowPanel,
    this.onMapLongPressHandle,
    this.onMapClickHandle,
    this.dMapName,
    this.heavenDataModelList,
    this.defaultLocation,
    this.defaultZoom,
    this.showCenterMarker,
  });
}
