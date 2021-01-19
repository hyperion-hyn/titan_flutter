import 'package:meta/meta.dart';

@immutable
abstract class LoadDataState {}

class InitialLoadDataState extends LoadDataState {}

class LoadingState extends LoadDataState {}

class LoadEmptyState extends LoadDataState {}

class LoadFailState extends LoadDataState {
  final String message;

  LoadFailState(this.message);
}

class RefreshingState extends LoadDataState {}

class RefreshSuccessState extends LoadDataState {}

//class RefreshEmptyState extends LoadDataState {}

class RefreshFailState extends LoadDataState {
  final String message;

  RefreshFailState(this.message);
}

class LoadingMoreState extends LoadDataState {}

class LoadingMoreSuccessState extends LoadDataState {}

class LoadMoreEmptyState extends LoadDataState {}

class LoadMoreFailState extends LoadDataState {}
