import 'package:meta/meta.dart';
import 'package:titan/src/business/infomation/model/news_detail.dart';

@immutable
abstract class HomeState {}

class InitialHomeState extends HomeState {
}

class MapOperatingState extends HomeState {
}

class HomeAnnouncementState extends HomeState {
  NewsDetail announcement;
  HomeAnnouncementState({this.announcement});
}