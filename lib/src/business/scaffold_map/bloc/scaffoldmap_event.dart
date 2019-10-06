import 'package:flutter/cupertino.dart';
import 'package:titan/src/model/poi_interface.dart';

abstract class ScaffoldMapEvent {
  const ScaffoldMapEvent();
}

class InitMapEvent extends ScaffoldMapEvent {
}

class SearchPoiEvent extends ScaffoldMapEvent {
  final IPoi poi;

  SearchPoiEvent({@required this.poi});
}

class ShowPoiEvent extends ScaffoldMapEvent {
  final IPoi poi;

  ShowPoiEvent({this.poi});
}

class ClearSelectPoiEvent extends ScaffoldMapEvent {
}