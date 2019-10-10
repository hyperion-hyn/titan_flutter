import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/model/poi_interface.dart';

import 'dapp/embassy/embassy.dart';
import 'dapp/nightlife/nightlife.dart';
import 'dapp/nightlife/nightlife_poi_panel.dart';
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
        var poi = await _getPoiByPosition(point, coordinates, 'layer-heaven-2c6bfb5fb5714f4f9f42ed01ac486a35');
        if (poi != null) {
          BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ShowPoiEvent(poi: poi));
        } else {
          BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ClearSelectPoiEvent());
        }
        return true;
      },
      onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
        print('on long press nightlife');
        return true;
      },
      panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
        return NightLifePanel(poi: poi, scrollController: scrollController,);
      },
      panelPaddingTop: (context) => MediaQuery.of(context).padding.top + 56 - 12 //减去drag的高度
      );
}

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
  defaultLocation: LatLng(40.73061, -73.937242),
  onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on map click embassy');
    return true;
  },
  onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on long press embassy');
    return true;
  },
  panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
    return Container(
      child: Text('poi panel embassy'),
    );
  },
);

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
  defaultLocation: LatLng(40.73061, -73.937242),
  onMapClickHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on map click police');
    return true;
  },
  onMapLongPressHandle: (BuildContext context, Point<double> point, LatLng coordinates) async {
    print('on long press police');
    return true;
  },
  panelBuilder: (BuildContext context, ScrollController scrollController, IDMapPoi poi) {
    return Container(
      child: Text('poi panel police'),
    );
  },
);

Future<IPoi> _getPoiByPosition(Point<double> point, LatLng coordinates, String layerId) async {
  var range = 20;
  Rect rect = Rect.fromLTRB(point.x - range, point.y - range, point.x + range, point.y + range);
  List features = await mapboxMapController?.queryRenderedFeaturesInRect(rect, [layerId], null);
  if (features != null && features.length > 0) {
    var firstFeature = json.decode(features[0]);
    var poi = _convertHeavenMapPoiInfoFromFeature(firstFeature);
    return poi;
  }

  return null;
}

HeavenMapPoiInfo _convertHeavenMapPoiInfoFromFeature(Map<String, dynamic> feature) {
  HeavenMapPoiInfo heavenMapPoiInfo = HeavenMapPoiInfo();

  print('xxxx $heavenMapPoiInfo');

  heavenMapPoiInfo.id = feature["id"] is int ? feature["id"].toString() : feature["id"];
  var lat = double.parse(feature["properties"]["lat"]);
  var lon = double.parse(feature["properties"]["lon"]);
  heavenMapPoiInfo.latLng = LatLng(lat, lon);
  heavenMapPoiInfo.time = feature["properties"]["time"];
  heavenMapPoiInfo.phone = feature["properties"]["telephone"];
  heavenMapPoiInfo.service = feature["properties"]["service"];
  heavenMapPoiInfo.address = feature["properties"]["address"];
  heavenMapPoiInfo.desc = feature["properties"]["desc"];
  heavenMapPoiInfo.name = feature["properties"]["name"];
  heavenMapPoiInfo.area = feature["properties"]["area"];
  return heavenMapPoiInfo;
}

MapboxMapController get mapboxMapController {
  return (Keys.mapKey.currentState as MapContainerState)?.mapboxMapController;
}

class DMapDefine {
  static Map<String, DMapCreationModel> kMapList = {
    'embassy': DMapCreationModel(
        dMapConfigModel: embassyDMapConfigModel,
        createDAppWidgetFunction: (context) {
          return Embassy();
        }),
    'nightlife': DMapCreationModel(
        dMapConfigModel: nightLifeDMapConfigModel,
        createDAppWidgetFunction: (context) {
          return NightLife();
        }),
    'policeStation': DMapCreationModel(
      dMapConfigModel: policeDMapConfigModel,
      createDAppWidgetFunction: (context) {
        return PoliceService();
      },
    )
  };
}
