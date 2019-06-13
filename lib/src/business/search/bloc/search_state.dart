import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchState extends Equatable {
  SearchState([List props = const []]) : super(props);
}

class InitialSearchState extends SearchState {}

class SearchLoadedState extends SearchState {
  final List<dynamic> items;
  final String currentSearchText;
  final bool isHistory;

  SearchLoadedState({@required this.items, @required this.currentSearchText, @required this.isHistory})
      : super([isHistory, currentSearchText, items]);

  SearchLoadedState copyWith({List<dynamic> items, bool isHistory, String searchText}) {
    return SearchLoadedState(
        items: items ?? this.items, isHistory: isHistory ?? this.isHistory, currentSearchText: currentSearchText ?? this.currentSearchText);
  }

  @override
  String toString() {
    return '$runtimeType(isHistory: $isHistory, currentSearchText: $currentSearchText, items: $items)';
  }
}

//class SearchErrorState extends SearchState {
//  final String msg;
//
//  SearchErrorState({this.msg});
//}
