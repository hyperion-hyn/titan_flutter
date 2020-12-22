import 'package:meta/meta.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';

@immutable
abstract class AccountState {}

class InitialAccountState extends AccountState {}

class UpdateMyCheckInInfoState extends AccountState {
  final CheckInModel checkInModel;
  UpdateMyCheckInInfoState({this.checkInModel});
}

class ClearMyCheckInInfoState extends AccountState {}


class UpdateFailState extends AccountState {}
