import 'package:equatable/equatable.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PositionEvent extends Equatable {
//  const PositionEvent();
  PositionEvent([List props = const []]) : super(props);
}

class AddPositionEvent extends PositionEvent {}

class SelectCategoryLoadingEvent extends PositionEvent {
}

class SelectCategoryResultEvent extends PositionEvent {
  String searchText;

  SelectCategoryResultEvent({this.searchText});
}

class SelectCategoryClearEvent extends PositionEvent {
}