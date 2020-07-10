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
            ? '请到设置页开启您的面容 ID'
            : '请到设置页开启您的Touch ID',
        lockOut: biometricType == BiometricType.face
            ? '面容 ID不可用，请稍后重试'
            : 'Touch ID不可用，请稍后重试');
    var androidStrings = AndroidAuthMessages(
      cancelButton: '取消',
      signInTitle: biometricType == BiometricType.face ? '面容识别' : '指纹识别',
      fingerprintRequiredTitle: '需要指纹',
      fingerprintSuccess: '指纹识别成功',
      fingerprintHint: '指纹传感器',
      fingerprintNotRecognized: '未检测到指纹',
      goToSettingsButton: '前往设置',
      goToSettingsDescription: biometricType == BiometricType.face
          ? '请到设置页开启您的面容 ID'
          : '请到设置页开启您的指纹识别',
    );

    try {
      authenticated = await auth.authenticateWithBiometrics(
          useErrorDialogs: false,
          stickyAuth: true,
          androidAuthStrings: androidStrings,
          iOSAuthStrings: iosStrings,
          sensitiveTransaction: true,
          localizedReason: '使用您的面容或指纹进行验证');
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('生物识别'),
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
                      child: Text('前往设置'))
                ],
              );
            });
      } else if (e.code == auth_error.notAvailable) {
        Fluttertoast.showToast(msg: '生物识别不可用');
      } else if (e.code == auth_error.passcodeNotSet) {
        Fluttertoast.showToast(msg: '请到设置页设置您的pin');
      } else if (e.code == auth_error.lockedOut) {
        Fluttertoast.showToast(msg: '失败次数过多，请稍后重试');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        Fluttertoast.showToast(msg: '失败次数过多，生物识别暂不可用');
      } else if (e.code == auth_error.otherOperatingSystem) {
        Fluttertoast.showToast(msg: '您在其他操作系统，暂不支持');
      }
    }
    return authenticated;
  }
}
