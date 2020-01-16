import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';
import 'package:titan/src/model/poi_interface.dart';

abstract class ScaffoldMapEvent {
  const ScaffoldMapEvent();
}

class InitMapEvent extends ScaffoldMapEvent {}

//---------------------
// poi
//---------------------

class SearchPoiEvent extends ScaffoldMapEvent {
  final IPoi poi;

  SearchPoiEvent({@required this.poi});
}

class ShowPoiEvent extends ScaffoldMapEvent {
  final IPoi poi;

  ShowPoiEvent({this.poi});
}

class ClearSelectPoiEvent extends ScaffoldMapEvent {}

//---------------------
// search
//---------------------
class SearchTextEvent extends ScaffoldMapEvent {
  String searchText;
  LatLng center;

  //is gaode search
  bool isGaodeSearch;
  int type;
  String stringType;

  SearchTextEvent({this.searchText, this.center, this.type, this.isGaodeSearch,this.stringType});
}

//---------------------
// route
//---------------------
class RouteEvent extends ScaffoldMapEvent {
  IPoi fromPoi;
  IPoi toPoi;
  String profile;
  String language;
  final int paddingTop;
  final int paddingLeft;
  final int paddingRight;
  final int paddingBottom;

  RouteEvent({
    this.fromPoi,
    this.profile,
    this.toPoi,
    this.language,
    this.paddingTop = 800,
    this.paddingLeft = 550,
    this.paddingRight = 550,
    this.paddingBottom = 400,
  });
}

class ExistRouteEvent extends ScaffoldMapEvent {}

//---------------------
// dmap
//---------------------

class InitDMapEvent extends ScaffoldMapEvent {
  final DMapConfigModel dMapConfigModel;

  InitDMapEvent({@required this.dMapConfigModel});
}

//bus event
class GoSearchEvent {
  String searchText;

  GoSearchEvent({this.searchText});
}

class ToMyLocationEvent {}

class OnMapMovedEvent {
  LatLng latLng;

  OnMapMovedEvent({@required this.latLng});
}
