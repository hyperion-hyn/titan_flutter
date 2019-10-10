import 'package:meta/meta.dart';

@immutable
abstract class HomeState {}

class InitialHomeState extends HomeState {}

//class ShowPoiState extends HomeState {
//  final IPoi poi;
//
//  ShowPoiState({this.poi});
//}

class MapOperatingState extends HomeState {
}