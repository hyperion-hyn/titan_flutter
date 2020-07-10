import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/plugins/titan_plugin.dart';

class AuthUtil {
  static Future<bool> bioAuth(
    BuildContext context,
    BiometricType biometricType,
  ) async {
    bool authenticated = false;
    LocalAuthentication auth = LocalAuthentication();

    var iosStrings = IOSAuthMessages(
        cancelButton: S.of(context).cancel,
        goToSettingsButton: S.of(context).go_to_settings,
        goToSettingsDescription: biometricType == BiometricType.face
            ? S.of(context).go_to_setting_page_open_face_id
            : S.of(context).go_to_setting_page_open_touch_id,
        lockOut: biometricType == BiometricType.face
            ? S.of(context).face_id_not_available_try_again
            : S.of(context).touch_id_not_available_try_again);
    var androidStrings = AndroidAuthMessages(
      cancelButton: S.of(context).cancel,
      signInTitle: biometricType == BiometricType.face ? S.of(context).face_recognition : S.of(context).fingerprint_recognition,
      fingerprintRequiredTitle: S.of(context).need_fingerprint,
      fingerprintSuccess: S.of(context).fingerprint_recognition_success,
      fingerprintHint: S.of(context).fingerprint_sensor,
      fingerprintNotRecognized: S.of(context).no_fingerprint_detected,
      goToSettingsButton: S.of(context).go_to_settings,
      goToSettingsDescription: biometricType == BiometricType.face
          ? S.of(context).go_to_setting_page_open_face_id
          : S.of(context).go_setting_open_fingerprint,
    );

    try {
      authenticated = await auth.authenticateWithBiometrics(
          useErrorDialogs: false,
          stickyAuth: true,
          androidAuthStrings: androidStrings,
          iOSAuthStrings: iosStrings,
          sensitiveTransaction: true,
          localizedReason: S.of(context).face_fingerprint_verify);
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(S.of(context).biometrics),
                content: Text(androidStrings.goToSettingsDescription),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(S.of(context).cancel)),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        TitanPlugin.jumpToBioAuthSetting();
                      },
                      child: Text(S.of(context).go_to_settings))
                ],
              );
            });
      } else if (e.code == auth_error.notAvailable) {
        Fluttertoast.showToast(msg: S.of(context).biometrics_unavailable);
      } else if (e.code == auth_error.passcodeNotSet) {
        Fluttertoast.showToast(msg: S.of(context).go_setting_page_set_pin);
      } else if (e.code == auth_error.lockedOut) {
        Fluttertoast.showToast(msg: S.of(context).too_many_fail_try_again);
      } else if (e.code == auth_error.permanentlyLockedOut) {
        Fluttertoast.showToast(msg: S.of(context).too_many_fail_biometrics_unavailable);
      } else if (e.code == auth_error.otherOperatingSystem) {
        Fluttertoast.showToast(msg: S.of(context).not_support_other_systems);
      }
    }
    return authenticated;
  }
}
