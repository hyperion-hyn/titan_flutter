import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class SearchEvent extends Equatable {
  SearchEvent([List props = const []]) : super(props);
}

class AddSearchItemEvent extends SearchEvent {
  final dynamic item;

  AddSearchItemEvent(this.item);
}

class FetchSearchItemsEvent extends SearchEvent {
  final bool isHistory;
  final String searchText;
  final LatLng center;
  final String language;

  FetchSearchItemsEvent({this.isHistory, this.searchText, this.center, this.language});

  @override
  String toString() {
    return '$runtimeType(isHistory: $isHistory, searchText: $searchText, center: $center, language: $language)';
  }
}

class ClearSearchHisotoryEvent extends SearchEvent {}
