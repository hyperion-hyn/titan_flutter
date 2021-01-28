import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  @override
  AuthState get initialState => InitialAuthState();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is SetBioAuthEvent) {
      yield SetBioAuthState(
        event.biometricType,
        event.value,
        event.wallet,
      );
    } else if (event is RefreshBioAuthConfigEvent) {
      yield RefreshBioAuthConfigState(event.wallet);
    }
  }
}
