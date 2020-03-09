import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class AddSearchItemEvent extends SearchEvent {
  final dynamic item;

  AddSearchItemEvent(this.item);

  @override
  List<Object> get props => [item];
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

  @override
  List<Object> get props => [isHistory, searchText, center, language];
}

class ClearSearchHisotoryEvent extends SearchEvent {
  @override
  List<Object> get props => [];
}
