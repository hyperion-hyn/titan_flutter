import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class LoadDataBloc extends Bloc<LoadDataEvent, LoadDataState> {
  @override
  LoadDataState get initialState => InitialLoadDataState();

  @override
  Stream<LoadDataState> mapEventToState(LoadDataEvent event) async* {
    if (event is LoadingEvent) {
      yield LoadingState();
    } else if (event is LoadEmptyEvent) {
      yield LoadEmptyState();
    } else if (event is LoadFailEvent) {
      yield LoadFailState(message: event.message);
    } else if (event is RefreshingEvent) {
      yield RefreshingState();
    } else if (event is RefreshSuccessEvent) {
      yield RefreshSuccessState();
    } else if (event is RefreshFailEvent) {
      yield RefreshFailState(message: event.message);
    } else if (event is LoadingMoreEvent) {
      yield LoadingMoreState();
    } else if (event is LoadingMoreSuccessEvent) {
      yield LoadingMoreSuccessState();
    } else if (event is LoadMoreEmptyEvent) {
      yield LoadMoreEmptyState();
    } else if (event is LoadMoreFailEvent) {
      yield LoadMoreFailState();
    }
  }
}
