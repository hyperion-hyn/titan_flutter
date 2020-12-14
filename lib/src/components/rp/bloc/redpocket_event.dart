import 'package:meta/meta.dart';

@immutable
abstract class RedPocketEvent {}

class UpdateMyLevelInfoEntityEvent extends RedPocketEvent {
  final String address;
  UpdateMyLevelInfoEntityEvent({this.address});
}
