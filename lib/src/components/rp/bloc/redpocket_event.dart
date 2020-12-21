import 'package:meta/meta.dart';

@immutable
abstract class RedPocketEvent {}

class UpdateMyLevelInfoEvent extends RedPocketEvent {
  final String address;
  UpdateMyLevelInfoEvent({this.address});
}

class UpdateStatisticsEvent extends RedPocketEvent {
  final String address;
  UpdateStatisticsEvent({this.address});
}


class ClearMyLevelInfoEvent extends RedPocketEvent {

}