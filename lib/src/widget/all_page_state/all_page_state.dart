import 'package:meta/meta.dart';

@immutable
abstract class AllPageState {}

class LoadingState extends AllPageState {}

class LoadEmptyState extends AllPageState {}

class LoadFailState extends AllPageState {
  final String message;

  LoadFailState({this.message = '加载失败'});
}