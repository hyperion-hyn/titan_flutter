import 'package:meta/meta.dart';

@immutable
abstract class LoadDataState {}

class InitialLoadDataState extends LoadDataState {}

class LoadingState extends LoadDataState {}

class LoadEmptyState extends LoadDataState {}

class LoadFailState extends LoadDataState {
  final String message;

  LoadFailState({this.message = '加载失败'});
}

class RefreshingState extends LoadDataState {}

class RefreshSuccessState extends LoadDataState {}

//class RefreshEmptyState extends LoadDataState {}

class RefreshFailState extends LoadDataState {
  final String message;

  RefreshFailState({this.message = '刷新失败'});
}

class LoadingMoreState extends LoadDataState {}

class LoadingMoreSuccessState extends LoadDataState {}

class LoadMoreEmptyState extends LoadDataState {}

class LoadMoreFailState extends LoadDataState {}
