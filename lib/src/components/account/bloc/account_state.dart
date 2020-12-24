import 'package:meta/meta.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/mine/model/user_info.dart';

@immutable
abstract class AccountState {}

class InitialAccountState extends AccountState {}

class UpdateCheckInInfoState extends AccountState {
  final CheckInModel checkInModel;
  UpdateCheckInInfoState({this.checkInModel});
}

class UpdateUserInfoState extends AccountState {
  final UserInfo userInfo;
  UpdateUserInfoState({this.userInfo});
}

class ClearDataState extends AccountState {}


class UpdateFailState extends AccountState {}
