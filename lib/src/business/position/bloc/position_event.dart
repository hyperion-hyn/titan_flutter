import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/business/position/model/business_time.dart';
import 'package:titan/src/business/position/model/category_item.dart';

@immutable
abstract class PositionEvent extends Equatable {
//  const PositionEvent();
  PositionEvent([List props = const []]) : super(props);
}

class AddPositionEvent extends PositionEvent {

}

// category
class SelectCategoryLoadingEvent extends PositionEvent {
}

class SelectCategoryResultEvent extends PositionEvent {
  String searchText;

  SelectCategoryResultEvent({this.searchText});
}

class SelectCategoryClearEvent extends PositionEvent {
}

class SelectCategorySelectedEvent extends PositionEvent {
  CategoryItem categoryItem;
  SelectCategorySelectedEvent({this.categoryItem});
}

class SelectTimeSelectedEvent extends PositionEvent {
  BusinessInfo timeItem;
  SelectTimeSelectedEvent({this.timeItem});
}

class SelectImageSelectedEvent extends PositionEvent {
}

class GetOpenCageEvent extends PositionEvent {
}

class StartPostPoiDataEvent extends PositionEvent {
}

class LoadingPostPoiDataEvent extends PositionEvent {
  double progress;
  LoadingPostPoiDataEvent(this.progress);
}

class SuccessPostPoiDataEvent extends PositionEvent {
}

class FailPostPoiDataEvent extends PositionEvent {
}