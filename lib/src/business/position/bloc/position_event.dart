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

}

// category
class SelectCategoryInitEvent extends PositionEvent {
}

class SelectCategoryLoadingEvent extends PositionEvent {
}

class SelectCategoryResultEvent extends PositionEvent {
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

// uploading
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

}

// confirm
class ConfirmPositionLoadingEvent extends PositionEvent {
}


class ConfirmPositionPageEvent extends PositionEvent {
  LatLng userPosition;
  ConfirmPositionPageEvent (this.userPosition);
}

class ConfirmPositionResultEvent extends PositionEvent {
  int answer;
  ConfirmPoiItem confirmPoiItem;
  ConfirmPositionResultEvent(this.answer,this.confirmPoiItem);
}