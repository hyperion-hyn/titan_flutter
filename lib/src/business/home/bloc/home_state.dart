import 'package:meta/meta.dart';
import 'package:titan/src/business/infomation/model/news_detail.dart';

@immutable
abstract class HomeState {}

class InitialHomeState extends HomeState {
  NewsDetail announcement;
  InitialHomeState({this.announcement});
}

class MapOperatingState extends HomeState {
}