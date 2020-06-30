import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import './bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  @override
  AuthState get initialState => InitialAuthState();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    // TODO: Add Logic
    if (event is UpdateAuthStatusEvent) {
      if (event.authorized != null) {
        yield UpdateAuthStatusState(authorized: event.authorized);
      }
    } else if (event is UpdateAuthConfigEvent) {
      if (event.authConfigModel != null) {
        //AppCache.saveValue(PrefsKey.AUTH_CONFIG, )
        yield UpdateAuthConfigState(authConfigModel: event.authConfigModel);
      }
    }
  }
}
