import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class AuthSettingPage extends StatefulWidget {
  @override
  BaseState<StatefulWidget> createState() {
    return _AuthSettingPageState();
  }
}

class _AuthSettingPageState extends BaseState<AuthSettingPage> {
  final LocalAuthentication auth = LocalAuthentication();
  List<BiometricType> _availableBiometrics = List();
  bool _canCheckBiometrics = false;
  bool _faceAuthEnabled = false;
  AuthConfigModel _authConfigModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAvailableBiometrics();
    _checkBiometrics();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    _authConfigModel = AuthInheritedModel.of(context).authConfigModel;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '快速验证',
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
            Text('Can check biometrics: $_canCheckBiometrics\n'),
            Center(
              child: Text(_canCheckBiometrics ? '已授权，可以开启' : '未授权，不可开启'),
            ),
            RaisedButton(
              child: Text('展示授权dialog'),
              onPressed: () {
                UiUtil.showAuthDialog(context);
              },
            ),
            Text('Available biometrics: $_availableBiometrics\n'),
            if (_availableBiometrics != null &&
                _availableBiometrics.contains(BiometricType.face))
              SwitchListTile(
                activeColor: Theme.of(context).primaryColor,
                title: Text('开启人脸验证'),
                value: _faceAuthEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _faceAuthEnabled = value;
                    if (!_faceAuthEnabled) {
                      _showDisableAuthDialog();
                    }
                  });
                },
              ),
            Divider(
              height: 1,
            ),
            if (_availableBiometrics != null &&
                _availableBiometrics.contains(BiometricType.fingerprint))
              SwitchListTile(
                title: Text('开启指纹识别'),
                value: true,
                onChanged: (bool value) {
                  setState(() {
                    Fluttertoast.showToast(msg: 'value: ${value}');
                  });
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

  _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }
}
