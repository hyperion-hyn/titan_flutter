import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';

import '../dmap/dmap.dart';

abstract class ScaffoldMapEvent {}

class DefaultMapEvent extends ScaffoldMapEvent {}

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

//---------------------
// search
//---------------------
class SearchTextEvent extends ScaffoldMapEvent {
  String searchText;
  LatLng center;

  //is category search
  bool isCategorySearch;
  int gaodeType; //only China mainland, type of gaode
  String typeOfNearBy; //only not China mainland, category of type

  SearchTextEvent({this.searchText, this.center, this.gaodeType, this.isCategorySearch, this.typeOfNearBy});
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

//class ExistRouteEvent extends ScaffoldMapEvent {}

//---------------------
// dmap
//---------------------

class EnterDMapEvent extends ScaffoldMapEvent {
  final DMapConfigModel dMapConfigModel;

  EnterDMapEvent({@required this.dMapConfigModel});
}

///just yield a state
///for example: back to a preview state
class YieldStateEvent extends ScaffoldMapEvent {
  final ScaffoldMapState state;

  YieldStateEvent({this.state});
}

//---------------------
// bus event
//---------------------
class GoSearchEvent {
  String searchText;

  GoSearchEvent({this.searchText});
}

class ToMyLocationEvent {
  final double zoom;

  ToMyLocationEvent({this.zoom});
}

class ClearSelectedPoiEvent {}

class OnMapMovedEvent {
  LatLng latLng;

  OnMapMovedEvent({@required this.latLng});
}
