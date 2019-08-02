import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:titan/src/model/poi_interface.dart';

@immutable
abstract class SearchbarState {}

class InitialSearchbarState extends SearchbarState {}

class SearchTextState extends SearchbarState {
  final bool isLoading;
  final String failMsg;
  final String searchText;
  final List<IPoi> pois;

  SearchTextState({
    this.isLoading,
    this.searchText,
    this.pois,
    this.failMsg,
  });

  SearchTextState copyWith(SearchTextState state) {
    if (state == null) {
      return this;
    }
    return SearchTextState(
      searchText: state.searchText ?? this.searchText,
      isLoading: state.isLoading ?? this.isLoading,
      failMsg: state.failMsg ?? this.failMsg,
      pois: state.pois ?? this.pois,
    );
  }
}

class SearchPoiState extends SearchbarState {
  final IPoi poi;

  final String prvSearchText;
  final List<IPoi> prvSearchPois;

  SearchPoiState({this.poi, this.prvSearchPois, this.prvSearchText});

  SearchPoiState copyWith(SearchPoiState state) {
    if(state == null) {
      return this;
    }
    return SearchPoiState(
      poi: state.poi ?? this.poi,
      prvSearchText: state.prvSearchText ?? this.prvSearchText,
      prvSearchPois: state.prvSearchPois ?? this.prvSearchPois,
    );
  }
}
