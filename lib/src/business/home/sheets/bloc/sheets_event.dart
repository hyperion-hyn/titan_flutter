import 'package:meta/meta.dart';
import 'package:titan/src/model/poi_interface.dart';

@immutable
abstract class SheetsEvent {}

class ShowPoiEvent extends SheetsEvent {
  final IPoi poi;

  ShowPoiEvent({this.poi});
}

class ShowSearchItemsEvent extends SheetsEvent {
  final List<dynamic> items;

  ShowSearchItemsEvent({this.items});
}

class ShowLoadingEvent extends SheetsEvent {}

class ShowLoadFailEvent extends SheetsEvent {
  final String message;

  ShowLoadFailEvent({this.message});
}

class CloseSheetEvent extends SheetsEvent {}
