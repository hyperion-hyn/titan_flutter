import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/dapp/dapp_define.dart';
import 'package:titan/src/model/poi_interface.dart';

abstract class ScaffoldMapState {
  const ScaffoldMapState();

  void setCurrentPoi(IPoi poi) {
    ScaffoldMapStore.shared.currentPoi = poi;
  }

  IPoi getCurrentPoi() {
    return ScaffoldMapStore.shared.currentPoi;
  }

  void setSearchPoiList(List<IPoi> list) {
    ScaffoldMapStore.shared.searchPoiList = list;
  }

  List<IPoi> getSearchPoiList() {
    return ScaffoldMapStore.shared.searchPoiList;
  }

  void appendSearchPoiList(List<IPoi> list) {
    if (ScaffoldMapStore.shared.searchPoiList == null) {
      ScaffoldMapStore.shared.searchPoiList = [];
    }
    if (list != null) {
      ScaffoldMapStore.shared.searchPoiList.addAll(list);
    }
  }

  void setSearchText(String text) {
    ScaffoldMapStore.shared.searchText = text;
  }

  String getSearchText() {
    return ScaffoldMapStore.shared.searchText;
  }

  DAppDefine getCurrentDapp() {
    return ScaffoldMapStore.shared.dapp;
  }

  void setCurrentDapp(DAppDefine dapp) {
    ScaffoldMapStore.shared.dapp = dapp;
  }
}

class InitialScaffoldMapState extends ScaffoldMapState {}

//-----------------
//  poi
//-----------------

class SearchingPoiState extends ScaffoldMapState {
  SearchingPoiState({IPoi searchingPoi}) {
    setCurrentPoi(searchingPoi);
  }
}

class ShowPoiState extends ScaffoldMapState {
  ShowPoiState({IPoi poi}) {
    setCurrentPoi(poi);
  }
}

class SearchPoiFailState extends ScaffoldMapState {
  final String message;

  SearchPoiFailState({IPoi poi, this.message}) {
    setCurrentPoi(poi);
  }
}

//-----------------
//  search by text
//-----------------

/// searching pois
class SearchingPoiByTextState extends ScaffoldMapState {
  SearchingPoiByTextState({String searchText}) {
    setSearchText(searchText);
  }
}

class SearchPoiByTextSuccessState extends ScaffoldMapState {
  SearchPoiByTextSuccessState({List<IPoi> list}) {
    appendSearchPoiList(list);
  }
}

class SearchPoiByTextFailState extends ScaffoldMapState {
  final String message;

  SearchPoiByTextFailState({this.message});
}

//-----------------
//  route
//-----------------

class RoutingState extends ScaffoldMapState {
  IPoi fromPoi;
  IPoi toPoi;
  String profile;
  String language;

  RoutingState({
    this.toPoi,
    this.profile,
    this.fromPoi,
    this.language,
  });
}

class RouteSuccessState extends ScaffoldMapState {
  IPoi fromPoi;
  IPoi toPoi;
  String profile;
  String language;
  RouteDataModel routeDataModel;

  RouteSuccessState({
    this.toPoi,
    this.profile,
    this.fromPoi,
    this.routeDataModel,
    this.language,
  });
}

class RouteFailState extends ScaffoldMapState {
  IPoi fromPoi;
  IPoi toPoi;
  String profile;
  String message;
  String language;

  RouteFailState({
    this.toPoi,
    this.profile,
    this.fromPoi,
    this.message,
    this.language,
  });
}

//-----------------
//  navigation
//-----------------

class NavigationState extends ScaffoldMapState {}

//-----------------
//  dapp night life
//-----------------
class NightLifeState extends ScaffoldMapState {}

//-----------------
//  dapp police
//-----------------
class PoliceState extends ScaffoldMapState {}
