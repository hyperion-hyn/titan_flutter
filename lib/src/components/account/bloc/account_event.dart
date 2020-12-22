import 'package:meta/meta.dart';

@immutable
abstract class AccountEvent {}

class UpdateMyCheckInInfoEvent extends AccountEvent {
  final String address;
  UpdateMyCheckInInfoEvent({this.address});
}

class ClearMyCheckInInfoEvent extends AccountEvent {}
