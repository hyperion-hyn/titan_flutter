import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

class SetBioAuthPage extends StatefulWidget {
  final Wallet _wallet;

  SetBioAuthPage(this._wallet);

  @override
  State<StatefulWidget> createState() {
    return _SetBioAuthPageState();
  }
}

class _SetBioAuthPageState extends BaseState<SetBioAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();
  List<BiometricType> _availableBiometrics = List();
  AuthConfigModel authConfigModel;

  @override
  Future<void> onCreated() async {
    // TODO: implement onCreated
    super.onCreated();
    authConfigModel = await AuthUtil.getAuthConfigByWallet(widget._wallet);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAvailableBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          S.of(context).secret_free_payment,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Image.asset(
                'res/drawable/ic_bio_auth.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
          if (_availableBiometrics.contains(BiometricType.face)) _faceAuth(),
          if (_availableBiometrics.contains(BiometricType.fingerprint))
            _fingerprintAuth(),
          _description()
        ],
      ),
    );
  }

  _faceAuth() {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        title: Text(S.of(context).face_recognition),
        value: authConfigModel.useFace,
        onChanged: (bool value) async {
          _setBioAuth(BiometricType.face, value);
        },
      ),
    );
  }

  _fingerprintAuth() {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        title: Text(S.of(context).fingerprint_recognition),
        value: authConfigModel.useFingerprint,
        onChanged: (bool value) async {
          _setBioAuth(BiometricType.fingerprint, value);
        },
      ),
    );
  }

  _description() {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 16,
              ),
              Text(
                S.of(context).introduct_non_secret_payment,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                S.of(context).non_secret_payment_introduction_detail,
                style: TextStyle(
                  height: 1.7,
                  fontSize: 13,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                S.of(context).remind_after_open_non_secret_payment,
                style: TextStyle(
                  height: 1.7,
                  fontSize: 13,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  S.of(context).risk_warning,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text(
                S.of(context).risk_warning_detail_non_secret_payment,
                style: TextStyle(
                  height: 1.8,
                  fontSize: 13,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  S.of(context).disclaimer,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text(
                S.of(context).disclaimer_detail_non_secret_payment,
                style: TextStyle(
                  height: 1.8,
                  fontSize: 13,
                ),
              )
            ],
          ),
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

  ///check password and bio-auth, if both valid then enable bio-auth
  Future<void> _setBioAuth(BiometricType biometricType, bool value) async {
    if (value) {
      ///Check password
      ///
      var password = await UiUtil.showPasswordDialog(
        context,
        widget._wallet,
        onCheckPwdValid: (String password) async {
          return WalletUtil.checkPwdValid(
            context,
            widget._wallet,
            password,
          );
        },
        isShowBioAuthIcon: false,
      );

      if (password != null) {
        var authResult = await AuthUtil.bioAuth(context, biometricType);

        ///then check bio-auth
        if (authResult) {
          ///Save password to SecureStorage
          await WalletUtil.savePwdToSecureStorage(
            context,
            widget._wallet,
            password,
          );
//          ///
//          BlocProvider.of<AuthBloc>(context).add(
//            SetBioAuthEvent(
//              biometricType,
//              true,
//              widget._wallet,
//            ),
//          );

          if (biometricType == BiometricType.face) {
            authConfigModel.useFace = true;
          } else if (biometricType == BiometricType.fingerprint) {
            authConfigModel.useFingerprint = true;
          }

          ///Update last auth time
          authConfigModel.lastBioAuthTime =
              DateTime.now().millisecondsSinceEpoch;

          ///Save auth config
          AuthUtil.saveAuthConfig(authConfigModel, widget._wallet);

          UiUtil.showHintToast(
              context,
              Image.asset(
                'res/drawable/ic_toast_check.png',
                width: 60,
                height: 60,
              ),
              S.of(context).set_bio_auth_success);
        } else {
          UiUtil.showHintToast(
              context,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'res/drawable/ic_toast_cross.png',
                  width: 30,
                  height: 30,
                ),
              ),
              S.of(context).set_bio_auth_fail);
        }
      } else {
        UiUtil.showHintToast(
            context,
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'res/drawable/ic_toast_cross.png',
                width: 30,
                height: 30,
              ),
            ),
            '开启失败');
      }
    } else {
//      BlocProvider.of<AuthBloc>(context).add(SetBioAuthEvent(
//        biometricType,
//        value,
//        widget._wallet,
//      ));
      if (biometricType == BiometricType.face) {
        authConfigModel.useFace = false;
      } else if (biometricType == BiometricType.fingerprint) {
        authConfigModel.useFingerprint = false;
      }
      authConfigModel.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;

      AuthUtil.saveAuthConfig(authConfigModel, widget._wallet);
    }
    if (mounted) setState(() {});
  }
}
