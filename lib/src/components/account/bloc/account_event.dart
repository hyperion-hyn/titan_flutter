import 'package:meta/meta.dart';

@immutable
abstract class AccountEvent {}

class UpdateCheckInInfoEvent extends AccountEvent {
  final String address;
  UpdateCheckInInfoEvent({this.address});
}

class UpdateUserInfoEvent extends AccountEvent {
  final String address;
  UpdateUserInfoEvent({this.address});
}

class ClearDataEvent extends AccountEvent {}
