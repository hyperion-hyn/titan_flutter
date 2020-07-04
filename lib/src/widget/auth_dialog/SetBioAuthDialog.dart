import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class SetBioAuthDialog extends StatefulWidget {
  final BiometricType biometricType;
  final String title;

  SetBioAuthDialog(this.biometricType, this.title);

  @override
  BaseState<StatefulWidget> createState() {
    return _SetBioAuthDialogState();
  }
}

class _SetBioAuthDialogState extends BaseState<SetBioAuthDialog> {
  final LocalAuthentication auth = LocalAuthentication();

  void initState() {
    super.initState();

    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 32.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _content()
                        ],
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            'res/drawable/ic_dialog_close.png',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _content() {
    if (widget.biometricType == BiometricType.face) {
      return _faceAuthWidget();
    } else {
      return _fingerprintAuthWidget();
    }
  }

  _faceAuthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            '您的设备支持面容识别功能，是否开启面容识别？',
            textAlign: TextAlign.center,
            style: TextStyle(color: HexColor('#FF999999')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.asset(
            'res/drawable/ic_face_id.png',
            width: 60,
            height: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Spacer(),
              InkWell(
                child: Text('暂不开启'),
                onTap: () {
                  Navigator.of(context).pop(false);
                },
              ),
              Spacer(),
              ClickOvalButton(
                '开启',
                () {
                  _authenticate();
                },
                width: 120,
              ),
              Spacer()
            ],
          ),
        )
      ],
    );
  }

  _fingerprintAuthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            '您的设备支持指纹识别功能，是否开启指纹识别？',
            textAlign: TextAlign.center,
            style: TextStyle(color: HexColor('#FF999999')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.asset(
            'res/drawable/ic_fingerprint.png',
            width: 60,
            height: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Spacer(),
              InkWell(
                child: Text('暂不开启'),
                onTap: () {
                  Navigator.of(context).pop(false);
                },
              ),
              Spacer(),
              ClickOvalButton(
                '开启',
                () {
                  _authenticate();
                },
                width: 120,
              ),
              Spacer()
            ],
          ),
        )
      ],
    );
  }

  _authenticate() async {
    bool authenticated = false;
    var iosStrings = IOSAuthMessages(
        cancelButton: '取消',
        goToSettingsButton: '前往设置',
        goToSettingsDescription: widget.biometricType == BiometricType.face
            ? '请到设置页开启您的面容 ID'
            : '请到设置页开启您的Touch ID',
        lockOut: widget.biometricType == BiometricType.face
            ? '请重新启用面容 ID'
            : '请重新使用的Touch ID');
    var androidStrings = AndroidAuthMessages(
      cancelButton: '取消',
      goToSettingsButton: '前往设置',
      goToSettingsDescription: widget.biometricType == BiometricType.face
          ? '请到设置页开启您的面容 ID'
          : '请到设置页开启您的指纹识别',
    );
    try {
      authenticated = await auth.authenticateWithBiometrics(
        useErrorDialogs: true,
        stickyAuth: true,
        localizedReason: 'Use your face or fingerprint to authorize.',
        androidAuthStrings: androidStrings,
        iOSAuthStrings: iosStrings,
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        Fluttertoast.showToast(msg: '暂不支持生物识别');
      } else if (e.code == auth_error.notAvailable) {
        Fluttertoast.showToast(msg: '您当前未开启Face ID授权，请前往设置中心开启');
      } else if (e.code == auth_error.passcodeNotSet) {
        Fluttertoast.showToast(msg: 'passcodeNotSet');
      } else if (e.code == auth_error.lockedOut) {
        Fluttertoast.showToast(msg: 'lockedOut');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        Fluttertoast.showToast(msg: 'permanentlyLockedOut');
      } else if (e.code == auth_error.otherOperatingSystem) {
        Fluttertoast.showToast(msg: 'otherOperatingSystem');
      }
    }
    Navigator.of(context).pop(authenticated);
  }
}
