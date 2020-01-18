import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/discover/dapp/encrypt_share/encrypt_share.dart';
import 'package:titan/src/business/discover/dapp/police_service/police_station_panel.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/model/poi_interface.dart';

import 'dapp/embassy/embassy.dart';
import 'dapp/embassy/embassy_poi_panel.dart';
import 'dapp/embassy/model/model.dart';
import 'dapp/encrypt_share/share_pois_panel.dart';
import 'dapp/nightlife/nightlife.dart';
import 'dapp/nightlife/nightlife_poi_panel.dart';
import 'dapp/police_service/model/model.dart';
import 'dapp/police_service/police_service.dart';

typedef CreateDAppWidgetFunction = Widget Function(BuildContext context);

class DMapCreationModel {
  final CreateDAppWidgetFunction createDAppWidgetFunction;
  final DMapConfigModel dMapConfigModel;

  DMapCreationModel({
    this.createDAppWidgetFunction,
    this.dMapConfigModel,
  });
}

///夜生活
DMapConfigModel get nightLifeDMapConfigModel {
  return DMapConfigModel(
      dMapName: 'nightlife',
      heavenDataModelList: <HeavenDataModel>[
        HeavenDataModel(
            id: '2c6bfb5fb5714f4f9f42ed01ac486a35',
            sourceLayer: 'heaven',
            sourceUrl: 'https://store.tile.map3.network/maps/global/heaven/{z}/{x}/{y}.vector.pbf',
            color: 0xffEE7AE9)
      ],
      defaultLocation: LatLng(22.296797, 114.170900),
      defaultZoom: 12,
      onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
        var poi;
        var feature = await _getFeature(point, coordinates, 'layer-heaven-2c6bfb5fb5714f4f9f42ed01ac486a35');
        if (feature != null) {
          poi = HeavenMapPoiInfo.fromMapFeature(feature);
          if (poi != null) {
            BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
          }
        }
        if (poi == null) {
          BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectPoiEvent());
        }
        return true;
      },
      onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
        print('on long press nightlife');
        return true;
      },
      panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
        return NightLifePanel(
          poi: poi,
          scrollController: scrollController,
        );
      },
      panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
      );
}

//大使馆
final embassyDMapConfigModel = DMapConfigModel(
    dMapName: 'embassy',
    heavenDataModelList: <HeavenDataModel>[
      HeavenDataModel(
        id: 'c1b7c5102eca43029f0416892447e0ed',
        sourceLayer: 'embassy',
        sourceUrl: "https://store.tile.map3.network/maps/global/embassy/{z}/{x}/{y}.vector.pbf",
        color: 0xff59B45F,
      )
    ],
    defaultLocation: LatLng(22.296797, 114.170900),
    defaultZoom: 12,
    onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      var poi;
      var feature = await _getFeature(point, coordinates, 'layer-heaven-c1b7c5102eca43029f0416892447e0ed');
      if (feature != null) {
        print('【D-map] --> $feature');
        poi = EmbassyPoi.fromMapFeature(feature);
        if (poi != null) {
          BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
        }
      }
      if (poi == null) {
        BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectPoiEvent());
      }
      return true;
    },
    onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      print('on long press embassy');
      return true;
    },
    panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
      return EmbassyPoiPanel(poi: poi, scrollController: scrollController);
    },
    panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
    );

//警察服务站
final policeDMapConfigModel = DMapConfigModel(
    dMapName: 'policeStation',
    heavenDataModelList: <HeavenDataModel>[
      HeavenDataModel(
        id: '3818230e27554203b638851aa246e7d3',
        sourceLayer: 'police',
        sourceUrl: "https://store.tile.map3.network/maps/global/police/{z}/{x}/{y}.vector.pbf",
        color: 0xff836FFF,
      )
    ],
    defaultLocation: LatLng(22.296797, 114.170900),
    defaultZoom: 12,
    onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      var poi;
      var feature = await _getFeature(point, coordinates, 'layer-heaven-3818230e27554203b638851aa246e7d3');
      if (feature != null) {
        poi = PoliceStationPoi.fromMapFeature(feature);
        if (poi != null) {
          BlocProvider.of<ScaffoldMapBloc>(context).add(ShowPoiEvent(poi: poi));
        }
      }
      if (poi == null) {
        BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectPoiEvent());
      }
      return true;
    },
    onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
      print('on long press police');
      return true;
    },
    panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
      return PoliceStationPanel(poi: poi, scrollController: scrollController);
    },
    panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
    );

//位置加密分享
final encryptShareDMapConfigModel = DMapConfigModel(
  dMapName: 'encryptShare',
  onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on click encrypt share');
    return true;
  },
  onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on long press encrypt share');
    return true;
  },
  alwaysShowPanel: true,
  panelDraggable: true,
  showCenterMarker: true,
  panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
    return SharePoisPanel(scrollController: scrollController);
  },
  panelPaddingTop: (context) => MediaQuery.of(context).size.height * 0.45,
  panelAnchorHeight: (context) => MediaQuery.of(context).size.height * 0.55,
  panelCollapsedHeight: (context) => 220,
);

Future<Map<String, dynamic>> _getFeature(Point<double> point, LatLng coordinates, String layerId) async {
  var range = 20;
  Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
  List features = await mapboxMapController?.queryRenderedFeaturesInRect(rect, [layerId], null);
  if (features != null && features.length > 0) {
    return json.decode(features[0]);
  }

  return null;
}

MapboxMapController get mapboxMapController {
  return (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController;
}

class DMapDefine {
  static Map<String, DMapCreationModel> kMapList = {
    'embassy': DMapCreationModel(
      dMapConfigModel: embassyDMapConfigModel,
      createDAppWidgetFunction: (context) => Embassy(),
    ),
    'nightlife': DMapCreationModel(
      dMapConfigModel: nightLifeDMapConfigModel,
      createDAppWidgetFunction: (context) => NightLife(),
    ),
    'policeStation': DMapCreationModel(
      dMapConfigModel: policeDMapConfigModel,
      createDAppWidgetFunction: (context) => PoliceService(),
    ),
    'encryptShare': DMapCreationModel(
      dMapConfigModel: encryptShareDMapConfigModel,
      createDAppWidgetFunction: (context) => EncryptShare(),
    ),
  };
}
