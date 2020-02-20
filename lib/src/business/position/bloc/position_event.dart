import 'package:equatable/equatable.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/business/position/model/confirm_poi_item.dart';
import 'package:titan/src/business/position/model/poi_data.dart';

@immutable
abstract class PositionEvent extends Equatable {
//  const PositionEvent();
  PositionEvent([List props = const []]) : super(props);
}

class AddPositionEvent extends PositionEvent {
//todo: delete
}

// category
class SelectCategoryInitEvent extends PositionEvent {
  //todo: 每个page 有个 bloc
  //todo: delete
}

class SelectCategoryLoadingEvent extends PositionEvent {
  //todo: delete
}

class SelectCategoryResultEvent extends PositionEvent {
  //todo: 命名问题
  final String searchText;

  SelectCategoryResultEvent({this.searchText});
}

class SelectCategoryClearEvent extends PositionEvent {
}

// get
class GetOpenCageEvent extends PositionEvent {
  final LatLng userPosition;
  GetOpenCageEvent(this.userPosition);
}

// uploading poi
class StartPostPoiDataEvent extends PositionEvent {
  final PoiDataModel poiDataModel;
  StartPostPoiDataEvent(this.poiDataModel);
}

class LoadingPostPoiDataEvent extends PositionEvent {
  final double progress;
  LoadingPostPoiDataEvent(this.progress);
}

class SuccessPostPoiDataEvent extends PositionEvent {
}

class FailPostPoiDataEvent extends PositionEvent {
  final int code;
  FailPostPoiDataEvent(this.code);
}

// confirm
class ConfirmPositionLoadingEvent extends PositionEvent {
}


class ConfirmPositionPageEvent extends PositionEvent {
  LatLng userPosition;
  ConfirmPositionPageEvent (this.userPosition);
}

class ConfirmPositionResultLoadingEvent extends PositionEvent {
}

class ConfirmPositionResultEvent extends PositionEvent {
  int answer;
  ConfirmPoiItem confirmPoiItem;
  ConfirmPositionResultEvent(this.answer,this.confirmPoiItem);
}


// uploading poi ncvo
class StartPostPoiNcovDataEvent extends PositionEvent {
  final PoiNcovDataModel poiDataModel;
  StartPostPoiNcovDataEvent(this.poiDataModel);
}

class LoadingPostPoiNcovDataEvent extends PositionEvent {
  final double progress;
  LoadingPostPoiNcovDataEvent(this.progress);
}

class SuccessPostPoiNcovDataEvent extends PositionEvent {
}

class FailPostPoiNcovDataEvent extends PositionEvent {
  final int code;
  FailPostPoiNcovDataEvent(this.code);
}