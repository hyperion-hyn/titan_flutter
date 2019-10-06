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

//bus event
class GoSearchEvent {
  String searchText;

  GoSearchEvent({this.searchText});
}
