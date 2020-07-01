import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/auth/bloc/bloc.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:titan/src/widget/enter_wallet_password.dart';

class AuthSettingPage extends StatefulWidget {
  @override
  BaseState<StatefulWidget> createState() {
    return _AuthSettingPageState();
  }
}

class _AuthSettingPageState extends BaseState<AuthSettingPage> {
  final LocalAuthentication auth = LocalAuthentication();
  List<BiometricType> _availableBiometrics = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAvailableBiometrics();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    //_authConfigModel = AuthInheritedModel.of(context).authConfigModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '生物识别',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Text('Available biometrics: $_availableBiometrics\n'),
            if (_availableBiometrics != null &&
                _availableBiometrics.contains(BiometricType.face))
              SwitchListTile(
                activeColor: Theme.of(context).primaryColor,
                title: Text('开启人脸验证'),
                value: AuthInheritedModel.of(context).authConfigModel.useFace,
                onChanged: (bool value) async {
                  if (value) {
                    var result = await _verifyWalletPwd();
                    if (result) _turnOnOrOffBioAuth(BiometricType.face, value);
                  } else {
                    _turnOnOrOffBioAuth(BiometricType.face, value);
                  }
                  setState(() {});
                },
              ),
            Divider(
              height: 1,
            ),
            if (_availableBiometrics != null &&
                _availableBiometrics.contains(BiometricType.fingerprint))
              SwitchListTile(
                title: Text('开启指纹识别'),
                value: AuthInheritedModel.of(context)
                    .authConfigModel
                    .useFingerprint,
                onChanged: (bool value) async {
                  if (value) {
                    var result = await _verifyWalletPwd();
                    if (result)
                      _turnOnOrOffBioAuth(BiometricType.fingerprint, value);
                  } else {
                    _turnOnOrOffBioAuth(BiometricType.fingerprint, value);
                  }
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  _showDisableAuthDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('确认取消'),
            content: Text('取消后会清除授权记录'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).cancel)),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).confirm))
            ],
          );
        },
        barrierDismissible: true);
  }

  Future<bool> _verifyWalletPwd() async {
    var password = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        });
    if (password != null) {
      ///Check pwd is valid here
      ///

      return _saveWalletPwdToSecureStorage(password);
    } else {
      return false;
    }
  }

  Future<bool> _saveWalletPwdToSecureStorage(String pwd) async {
    return true;
  }

  _turnOnOrOffBioAuth(BiometricType biometricType, bool value) {
    AuthConfigModel authConfigModel =
        AuthInheritedModel.of(context).authConfigModel;
    if (biometricType == BiometricType.face) {
      authConfigModel.useFace = value;
    } else if (biometricType == BiometricType.fingerprint) {
      authConfigModel.useFingerprint = value;
    }
    BlocProvider.of<AuthBloc>(context).add(UpdateAuthConfigEvent(
      authConfigModel: authConfigModel,
    ));
  }
}
