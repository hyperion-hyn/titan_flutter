import 'package:meta/meta.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/me/model/user_info.dart';
import 'package:titan/src/pages/me/model/user_token.dart';

@immutable
abstract class AccountEvent {}

class UpdateUserEvent extends AccountEvent {
  final UserInfo userInfo;

  UpdateUserEvent({
    this.userInfo,
  });
}

class LoggedEvent extends AccountEvent {
  final UserToken userToken;

  LoggedEvent({
    this.userToken,
  });
}

class LogoutUserEvent extends AccountEvent {}

class UpdateCheckInEvent extends AccountEvent {
  final CheckInModel checkInModel;

  UpdateCheckInEvent({this.checkInModel});
}
