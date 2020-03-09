import 'package:meta/meta.dart';

@immutable
abstract class LoadDataEvent {}

class LoadingEvent extends LoadDataEvent {}

class LoadEmptyEvent extends LoadDataEvent {}

class LoadFailEvent extends LoadDataEvent {
  final String message;

  LoadFailEvent({this.message});
}

class RefreshingEvent extends LoadDataEvent {}

class RefreshSuccessEvent extends LoadDataEvent {}

//class RefreshEmptyEvent extends LoadDataEvent {}

class RefreshFailEvent extends LoadDataEvent {
  final String message;

  RefreshFailEvent({this.message});
}

class LoadingMoreEvent extends LoadDataEvent {}

class LoadingMoreSuccessEvent extends LoadDataEvent {}

class LoadMoreEmptyEvent extends LoadDataEvent {}

class LoadMoreFailEvent extends LoadDataEvent {}
