import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/config/consts.dart';
import '../dmap/dmap.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';

abstract class ScaffoldMapState {
//  const ScaffoldMapState();
//
//  void setCurrentPoi(IPoi poi) {
//    ScaffoldMapStore.shared.currentPoi = poi;
//  }
//
//  IPoi getCurrentPoi() {
//    return ScaffoldMapStore.shared.currentPoi;
//  }
//
//  void setSearchPoiList(List<IPoi> list) {
//    ScaffoldMapStore.shared.searchPoiList = list;
//  }
//
//  List<IPoi> getSearchPoiList() {
//    return ScaffoldMapStore.shared.searchPoiList;
//  }
//
//  void appendSearchPoiList(List<IPoi> list) {
//    if (ScaffoldMapStore.shared.searchPoiList == null) {
//      ScaffoldMapStore.shared.searchPoiList = [];
//    }
//    if (list != null) {
//      ScaffoldMapStore.shared.searchPoiList.addAll(list);
//    }
//  }
//
//  void setSearchText(String text) {
//    ScaffoldMapStore.shared.searchText = text;
//  }
//
//  String getSearchText() {
//    return ScaffoldMapStore.shared.searchText;
//  }
//
//  DMapConfigModel get dMapConfigModel {
//    return ScaffoldMapStore.shared.dMapConfigModel;
//  }
//
//  set dMapConfigModel(DMapConfigModel viewModel) {
//    ScaffoldMapStore.shared.dMapConfigModel = viewModel;
//  }
}

class DefaultScaffoldMapState extends ScaffoldMapState {}

//-----------------
//  focus poi state
//-----------------

class FocusingPoiState extends ScaffoldMapState with EquatableMixin {
  final Status status;
  final IPoi poi;
  final String message;

  FocusingPoiState({this.status, this.message, this.poi});

  @override
  List<Object> get props => [status, poi, message];

  @override
  bool get stringify => true;
}
//
//class SearchingPoiState extends ScaffoldMapState {
//  SearchingPoiState({IPoi searchingPoi}) {
//    setCurrentPoi(searchingPoi);
//  }
//}
//
//class ShowPoiState extends ScaffoldMapState {
//  ShowPoiState({IPoi poi}) {
//    setCurrentPoi(poi);
//  }
//}
//
//class SearchPoiFailState extends ScaffoldMapState {
//  final String message;
//
//  SearchPoiFailState({IPoi poi, this.message}) {
//    setCurrentPoi(poi);
//  }
//}

//----------------------
//  focus search state
//----------------------

class FocusingSearchState extends ScaffoldMapState with EquatableMixin {
  final Status status;
  final String searchText;
  final List<IPoi> pois;
  final String message;

  FocusingSearchState({this.status, this.message, this.pois, this.searchText});

  @override
  List<Object> get props => [status, pois, message, searchText];

  @override
  bool get stringify => true;
}

///// searching pois
//class SearchingPoiByTextState extends ScaffoldMapState {
//  SearchingPoiByTextState({String searchText}) {
//    setSearchText(searchText);
//  }
//}
//
//class SearchPoiByTextSuccessState extends ScaffoldMapState {
//  SearchPoiByTextSuccessState({List<IPoi> list}) {
//    appendSearchPoiList(list);
//  }
//}
//
//class SearchPoiByTextFailState extends ScaffoldMapState {
//  final String message;
//
//  SearchPoiByTextFailState({this.message});
//}

//----------------------
//  focus route state
//----------------------
class FocusingRouteState extends ScaffoldMapState with EquatableMixin {
  final Status status;
  final IPoi fromPoi;
  final IPoi toPoi;
  final String profile; //enum RouteProfile;
  final String language;
  final String message;
  final RouteDataModel routeDataModel;

  FocusingRouteState({
    this.status,
    this.message,
    this.fromPoi,
    this.toPoi,
    this.language,
    this.profile,
    this.routeDataModel,
  });

  @override
  List<Object> get props => [status, message, fromPoi, toPoi, language, profile];

  @override
  bool get stringify => true;
}

//abstract class MapRouteState extends ScaffoldMapState {}
//
//class RoutingState extends MapRouteState {
//  IPoi fromPoi;
//  IPoi toPoi;
//  String profile;
//  String language;
//
//  RoutingState({
//    this.toPoi,
//    this.profile,
//    this.fromPoi,
//    this.language,
//  });
//}
//
//class RouteSuccessState extends MapRouteState {
//  IPoi fromPoi;
//  IPoi toPoi;
//  String profile;
//  String language;
//  RouteDataModel routeDataModel;
//
//  RouteSuccessState({
//    this.toPoi,
//    this.profile,
//    this.fromPoi,
//    this.routeDataModel,
//    this.language,
//  });
//}
//
//class RouteFailState extends MapRouteState {
//  IPoi fromPoi;
//  IPoi toPoi;
//  String profile;
//  String message;
//  String language;
//
//  RouteFailState({
//    this.toPoi,
//    this.profile,
//    this.fromPoi,
//    this.message,
//    this.language,
//  });
//}

//-----------------
//  navigation
//-----------------

//class NavigationState extends ScaffoldMapState {}

//-----------------
//  dmap
//-----------------
//abstract class BaseDMapState extends ScaffoldMapState {}

class FocusingDMapState extends ScaffoldMapState {
  final DMapConfigModel dMapConfigModel;

  FocusingDMapState({@required this.dMapConfigModel});
}
