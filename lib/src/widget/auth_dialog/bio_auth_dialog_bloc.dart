import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import './bloc.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'dart:convert';

@deprecated
class BioAuthDialogBloc extends Bloc<BioAuthDialogEvent, BioAuthDialogState> {
  @override
  BioAuthDialogState get initialState => InitialAuthDialogState();

  AuthConfigModel _authConfigModel;

  final LocalAuthentication auth = LocalAuthentication();
  List<BiometricType> _availableBiometricTypes = List();

  int _bioAuthRemainCount = 3;
  int _bioAuthMaxCount = 3;



  @override
  Stream<BioAuthDialogState> mapEventToState(
    BioAuthDialogEvent event,
  ) async* {
    if (event is CheckAuthConfigEvent) {
//      var authConfigStr = await AppCache.getValue<String>(PrefsKey.AUTH_CONFIG);
      // _authConfigModel = AuthConfigModel.fromJson(json.decode(authConfigStr));
//      _authConfigModel = AuthConfigModel(
//        useFace: true,
//        useFingerprint: true,
//        bioAuthEnabled: true,
//      );
      _checkAvailableBioMetrics();
    } else if (event is CheckBioAuthEvent) {
    } else if (event is ShowBioAuthRemainCountEvent) {
      yield ShowBioAuthRemainCountState(event.remainCount);
    }  else if (event is ShowFaceAuthEvent) {
      yield ShowFaceAuthState(
        remainCount: event.remainCount,
        maxCount: event.maxCount,
      );
    } else if (event is ShowFingerprintAuthEvent) {
      yield ShowFingerprintAuthState(
        remainCount: event.remainCount,
        maxCount: event.maxCount,
      );
    } else if (event is BioAuthStartEvent) {
      _authenticate();
    } else if (event is AuthCompletedEvent) {
      yield AuthCompletedState(event.result);
    }
  }

  _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          useErrorDialogs: true,
          stickyAuth: true,
          localizedReason: 'Use your face or fingerprint to authorize.');
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).not_support_biometrics);
      } else if (e.code == auth_error.notAvailable) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).not_enable_face_authorization_go_settings);
      } else if (e.code == auth_error.passcodeNotSet) {
        Fluttertoast.showToast(msg: 'passcodeNotSet');
      } else if (e.code == auth_error.lockedOut) {
        Fluttertoast.showToast(msg: 'lockedOut');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        Fluttertoast.showToast(msg: 'permanentlyLockedOut');
      } else if (e.code == auth_error.otherOperatingSystem) {
        Fluttertoast.showToast(msg: 'otherOperatingSystem');
      }

      //this.add(ShowPasswordAuthEvent());
      this.add(AuthCompletedEvent(false));
    }

    if (!authenticated) {
      _bioAuthRemainCount--;
      if (_bioAuthRemainCount == 0) {
        //this.add(ShowPasswordAuthEvent());
        this.add(AuthCompletedEvent(false));
      } else {
        _showAuthWidget();
      }
    } else {
      this.add(AuthCompletedEvent(true));
    }
  }

  _checkAvailableBioMetrics() async {
    try {
      _availableBiometricTypes = await auth.getAvailableBiometrics();
      _showAuthWidget();
    } on PlatformException catch (e) {
      this.add(AuthCompletedEvent(false));
      //this.add(ShowPasswordAuthEvent());
      print(e);
    }
  }

  _showAuthWidget() {
    if (_availableBiometricTypes.contains(BiometricType.face)) {
      this.add(ShowFaceAuthEvent(
        remainCount: _bioAuthRemainCount,
        maxCount: _bioAuthMaxCount,
      ));
      if (_bioAuthRemainCount == _bioAuthMaxCount) _authenticate();
    } else if (_availableBiometricTypes.contains(BiometricType.fingerprint)) {
      this.add(ShowFingerprintAuthEvent(
        remainCount: _bioAuthRemainCount,
        maxCount: _bioAuthMaxCount,
      ));
      if (_bioAuthRemainCount == _bioAuthMaxCount) _authenticate();
    } else {
      this.add(AuthCompletedEvent(false));
      //this.add(ShowPasswordAuthEvent());
    }
  }
}
