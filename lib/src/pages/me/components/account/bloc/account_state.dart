import 'package:meta/meta.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/me/model/user_info.dart';
import 'package:titan/src/pages/me/model/user_token.dart';

@immutable
abstract class AccountState {}

class InitialAccountState extends AccountState {}

class UserUpdateState extends AccountState {
  final UserInfo userInfo;

  UserUpdateState({
    this.userInfo,
  });
}

class LogoutState extends AccountState {}

class LoggedState extends AccountState {
  final UserToken userToken;

  LoggedState({
    this.userToken,
  });
}

class UpdateCheckInState extends AccountState {
  final CheckInModel checkInModel;

  UpdateCheckInState({this.checkInModel});
}
