import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/poi_interface.dart';

@immutable
abstract class SearchbarEvent {}

class ShowSearchEvent extends SearchbarEvent {
  final bool isLoading;
  final String failMsg;
  final String searchText;
  final List<IPoi> pois;

  ShowSearchEvent({
    this.isLoading,
    this.searchText,
    this.pois,
    this.failMsg,
  });

  ShowSearchEvent copyWith(ShowSearchEvent event) {
    if (event == null) {
      return this;
    }
    return ShowSearchEvent(
      isLoading: event.isLoading ?? this.isLoading,
      searchText: event.searchText ?? this.searchText,
      pois: event.pois ?? this.pois,
      failMsg: event.failMsg ?? this.failMsg,
    );
  }
}

class ShowPoiEvent extends SearchbarEvent {
  final IPoi poi;
  final String prvSearchText;

  ShowPoiEvent({this.poi, this.prvSearchText});
}

class ExistSearchEvent extends SearchbarEvent {}

class HideSearchBarEvent extends SearchbarEvent {}
