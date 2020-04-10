import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  @override
  AccountState get initialState => InitialAccountState();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is UpdateUserEvent) {
      if (event.userInfo != null) {
        await AppCache.saveValue(PrefsKey.SHARED_PREF_USER_INFO_KEY, json.encode(event.userInfo.toJson()));
      }

      yield UserUpdateState(
        userInfo: event.userInfo,
      );
    } else if (event is LoggedEvent) {
      await AppCache.saveValue(PrefsKey.SHARED_PREF_USER_TOKEN_KEY, json.encode(event.userToken.toJson()));

      yield LoggedState(userToken: event.userToken);
    } else if (event is LogoutUserEvent) {
      await AppCache.remove(PrefsKey.SHARED_PREF_USER_INFO_KEY);
      await AppCache.remove(PrefsKey.SHARED_PREF_USER_TOKEN_KEY);

      yield LogoutState();
    } else if (event is UpdateCheckInEvent) {
      yield UpdateCheckInState(checkInModel: event.checkInModel);
    }
  }
}
