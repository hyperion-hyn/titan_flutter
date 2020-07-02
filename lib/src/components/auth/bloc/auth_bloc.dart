import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import './bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  @override
  AuthState get initialState => InitialAuthState();

  AuthConfigModel authConfigModel;

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
        authConfigModel = event.authConfigModel;

        await AppCache.saveValue<String>('${PrefsKey.AUTH_CONFIG}',
            json.encode(event.authConfigModel.toJSON()));

        yield UpdateAuthConfigState(authConfigModel: event.authConfigModel);
      }
    } else if (event is SetBioAuthEvent) {
      if (authConfigModel != null) {
        if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.face)) {
          authConfigModel.useFace = event.value;
        }
        if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.fingerprint)) {
          authConfigModel.useFingerprint = event.value;
        }

        if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.iris)) {
          authConfigModel.useFingerprint = event.value;
        }

        authConfigModel.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;

        await AppCache.saveValue<String>(
            '${PrefsKey.AUTH_CONFIG}',
            json.encode(
              authConfigModel.toJSON(),
            ));

        yield UpdateAuthConfigState(authConfigModel: authConfigModel);
      }
    } else if (event is UpdateLastBioAuthTimeEvent) {
      if (authConfigModel != null) {
        authConfigModel.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;
        await AppCache.saveValue<String>(
            '${PrefsKey.AUTH_CONFIG}',
            json.encode(
              authConfigModel.toJSON(),
            ));
        ///Update pwd in secureStorage
        await AppCache.secureSaveValue(
          '${SecurePrefsKey.WALLET_PWD_KEY_PREFIX}${event.walletAddress}',
          event.walletPwd,
        );
        yield UpdateAuthConfigState(authConfigModel: authConfigModel);
      }
    }
  }
}
