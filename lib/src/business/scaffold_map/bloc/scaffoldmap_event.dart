import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
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

  SearchTextEvent({this.searchText, this.center});
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

//bus event
class GoSearchEvent {
  String searchText;

  GoSearchEvent({this.searchText});
}

class ToMyLocationEvent {}
