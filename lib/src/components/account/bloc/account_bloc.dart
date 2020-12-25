import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/mine/api/contributions_api.dart';
import 'package:titan/src/pages/mine/model/user_info.dart';
import 'bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  var _api = ContributionsApi();

  @override
  AccountState get initialState => InitialAccountState();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    try {
      if (event is UpdateCheckInInfoEvent) {
        CheckInModel checkInTask = await _api.checkInCountV3();

        yield UpdateCheckInInfoState(checkInModel: checkInTask);
      } else if (event is UpdateUserInfoEvent) {
        UserInfo userInfo = await _api.getAcceleration();

        yield UpdateUserInfoState(userInfo: userInfo);
      } else if (event is ClearDataEvent) {
        yield ClearDataState();
      }
    } catch (e) {
      yield UpdateFailState();
    }
  }
}
