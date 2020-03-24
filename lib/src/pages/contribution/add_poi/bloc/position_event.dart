import 'package:equatable/equatable.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_data.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';

@immutable
abstract class PositionEvent {
//  const PositionEvent();
  PositionEvent();

}

class AddPositionEvent extends PositionEvent {
//todo: delete
}

// category
class SelectCategoryInitEvent extends PositionEvent {
  String address;
  String language;
  SelectCategoryInitEvent(this.address,this.language);
  //todo: 每个page 有个 bloc
  //todo: delete
}

class SelectCategoryLoadingEvent extends PositionEvent {
  //todo: delete
}

class SelectCategoryResultEvent extends PositionEvent {
  //todo: 命名问题
  final String searchText;
  String address;
  String language;

  SelectCategoryResultEvent(this.address,this.language,{this.searchText});
}

class SelectCategoryClearEvent extends PositionEvent {}

// get
class GetOpenCageEvent extends PositionEvent {
  final LatLng userPosition;
  String language;

  GetOpenCageEvent(this.userPosition,this.language);
}

// uploading poi
class StartPostPoiDataEvent extends PositionEvent {
  final PoiDataModel poiDataModel;
  String address;

  StartPostPoiDataEvent(this.poiDataModel,this.address);
}

class LoadingPostPoiDataEvent extends PositionEvent {
  final double progress;

  LoadingPostPoiDataEvent(this.progress);
}

class SuccessPostPoiDataEvent extends PositionEvent {}

class FailPostPoiDataEvent extends PositionEvent {
  final int code;

  FailPostPoiDataEvent(this.code);
}

// confirm
class ConfirmPositionLoadingEvent extends PositionEvent {
}

class ConfirmPositionPageEvent extends PositionEvent {
  LatLng userPosition;
  String language;
  String address;
  ConfirmPositionPageEvent(this.userPosition,this.language,this.address);
}

class ConfirmPositionResultLoadingEvent extends PositionEvent {}

class ConfirmPositionResultEvent extends PositionEvent {
  int answer;
  UserContributionPoi confirmPoiItem;
  String address;
  ConfirmPositionResultEvent(this.answer, this.confirmPoiItem,this.address);
}

// uploading poi ncvo
class StartPostPoiNcovDataEvent extends PositionEvent {
  final PoiNcovDataModel poiDataModel;
  String address;
  StartPostPoiNcovDataEvent(this.poiDataModel,this.address);
}

class LoadingPostPoiNcovDataEvent extends PositionEvent {
  final double progress;

  LoadingPostPoiNcovDataEvent(this.progress);
}

class SuccessPostPoiNcovDataEvent extends PositionEvent {}

class FailPostPoiNcovDataEvent extends PositionEvent {
  final int code;

  FailPostPoiNcovDataEvent(this.code);
}
