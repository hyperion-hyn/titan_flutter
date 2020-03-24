import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../map.dart';
import '../scaffold_map.dart';

typedef ContextFun = double Function(BuildContext context);

class DMapConfigModel {

  // 地图-heaven-名字
  final String dMapName;

  // 地图-heaven-模型组
  final List<HeavenDataModel> heavenDataModelList;

  // 地图-heaven-初始化放大倍数
  final double defaultZoom;

  // 地图-heaven-初始化坐标
  final LatLng defaultLocation;

  // 地图-heaven-点击某个点的处理
  final OnMapClickHandle onMapClickHandle;

  // 地图-heaven-长按某个点的处理
  final OnMapLongPressHandle onMapLongPressHandle;

  // 底部操作panel初始化方法
  final PanelBuilder panelBuilder;

  // 底部操作panel距离状态栏顶部的高度
  final ContextFun panelPaddingTop;

  // 底部操作panel是否可以拖动
  final bool panelDraggable;

  // 底部操作panel收起来的高度
  final ContextFun panelCollapsedHeight;

  // 底部操作panel悬挂半空中的高度
  final ContextFun panelAnchorHeight;

  // 是否展示底部操作panel
  final bool alwaysShowPanel;

  // 是否展示中心锚点（即大头针）
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
