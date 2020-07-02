import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/auth/bloc/bloc.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
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
  Wallet _wallet;

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
    _wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '面容/指纹与密码',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: HexColor('#FFF2F2F2'),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('开启快捷验证功能'),
            ),
            if (_availableBiometrics != null &&
                _availableBiometrics.contains(BiometricType.face))
              Material(
                elevation: 0,
                child: SwitchListTile(
                  activeColor: Theme.of(context).primaryColor,
                  title: Text('人脸验证'),
                  value: AuthInheritedModel.of(context).authConfigModel.useFace,
                  onChanged: (bool value) async {
                    if (value) {
                      _requestWalletPwd();
                    } else {
                      _turnOnOrOffBioAuth(BiometricType.face, value);
                    }
                    setState(() {});
                  },
                ),
              ),
            Divider(
              height: 1,
            ),
            if (_availableBiometrics != null &&
                _availableBiometrics.contains(BiometricType.fingerprint))
              SwitchListTile(
                title: Text('指纹识别'),
                value: AuthInheritedModel.of(context)
                    .authConfigModel
                    .useFingerprint,
                onChanged: (bool value) async {
                  if (value) {
                    _requestWalletPwd();
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

  _requestWalletPwd() async {
    ///Use password dialog
    ///
    var pwdUseDigits = await WalletUtil.checkUseDigitsPwd(
      _wallet.getEthAccount().address,
    );
    var password = await UiUtil.showPasswordDialog(context, pwdUseDigits);

    ///Check password is valid
    ///
    var result = await WalletUtil.exportPrivateKey(
      fileName: _wallet.keystore.fileName,
      password: password,
    );
    if (result != null) {
      ///Save password
      await AppCache.secureSaveValue(
        '${SecurePrefsKey.WALLET_PWD_KEY_PREFIX}${_wallet.getEthAccount().address}',
        password,
      );
      BlocProvider.of<AuthBloc>(context).add(SetBioAuthEvent(
        value: true,
      ));
    } else {
      Fluttertoast.showToast(msg: '密码错误');
    }
    setState(() {});
  }

  _turnOnOrOffBioAuth(BiometricType biometricType, bool value) {
    BlocProvider.of<AuthBloc>(context).add(SetBioAuthEvent(value: value));
  }
}
