import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

class BioAuthPage extends StatefulWidget {
  final Wallet _wallet;
  final AuthType _authType;

  BioAuthPage(
    this._wallet,
    this._authType,
  );

  @override
  State<StatefulWidget> createState() {
    return _BioAuthPageState();
  }
}

class _BioAuthPageState extends BaseState<BioAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();
  List<BiometricType> _availableBiometrics = List();
  AuthConfigModel authConfigModel;

  @override
  Future<void> onCreated() async {
    super.onCreated();
    authConfigModel = await AuthUtil.getAuthConfigByWallet(
      widget._wallet,
      authType: widget._authType,
    );
  }

  @override
  void initState() {
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
          widget._authType == AuthType.pay
              ? S.of(context).secret_free_payment
              : S.of(context).exchange_bio_auth,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _icon(),
          if (_availableBiometrics.contains(BiometricType.face)) _faceAuth(),
          if (_availableBiometrics.contains(BiometricType.fingerprint)) _fingerprintAuth(),
          _description()
        ],
      ),
    );
  }

  _icon() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Image.asset(
            'res/drawable/ic_bio_auth.png',
            width: 60,
            height: 60,
          ),
        ),
      ),
    );
  }

  _faceAuth() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  S.of(context).face_recognition,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              FlutterSwitch(
                width: 54.0,
                height: 26.0,
                toggleSize: 18.0,
                activeColor: HexColor('#EDC313'),
                inactiveColor: HexColor('#DEDEDE'),
                value: authConfigModel?.useFace,
                onToggle: (value) {
                  _setBioAuth(BiometricType.face, value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _fingerprintAuth() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  S.of(context).fingerprint_recognition,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              FlutterSwitch(
                width: 54.0,
                height: 26.0,
                toggleSize: 18.0,
                activeColor: HexColor('#EDC313'),
                inactiveColor: HexColor('#DEDEDE'),
                value: authConfigModel.useFingerprint,
                onToggle: (value) {
                  _setBioAuth(BiometricType.fingerprint, value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _description() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Text(
              widget._authType == AuthType.pay
                  ? S.of(context).introduct_non_secret_payment
                  : S.of(context).bio_auth_intro_title_exchange,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              widget._authType == AuthType.pay
                  ? S.of(context).non_secret_payment_introduction_detail
                  : S.of(context).bio_auth_exchange_intro_content,
              style: TextStyle(height: 1.7, fontSize: 13, color: DefaultColors.color999),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              widget._authType == AuthType.pay
                  ? S.of(context).remind_after_open_non_secret_payment
                  : S.of(context).bio_auth_exchange_intro_content_2,
              style: TextStyle(height: 1.7, fontSize: 13, color: DefaultColors.color999),
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
              widget._authType == AuthType.pay
                  ? S.of(context).risk_warning_detail_non_secret_payment
                  : S.of(context).bio_auth_exchange_risk_content,
              style: TextStyle(height: 1.8, fontSize: 13, color: DefaultColors.color999),
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
              style: TextStyle(height: 1.8, fontSize: 13, color: DefaultColors.color999),
            )
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
        authType: widget._authType,
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

          if (biometricType == BiometricType.face) {
            authConfigModel.useFace = true;
          } else if (biometricType == BiometricType.fingerprint) {
            authConfigModel.useFingerprint = true;
          }

          ///Update last auth time
          authConfigModel.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;

          ///Save auth config
          AuthUtil.saveAuthConfig(
            authConfigModel,
            widget._wallet,
            authType: widget._authType,
          );

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
            S.of(context).set_bio_auth_fail);
      }
    } else {
      if (biometricType == BiometricType.face) {
        authConfigModel.useFace = false;
      } else if (biometricType == BiometricType.fingerprint) {
        authConfigModel.useFingerprint = false;
      }
      authConfigModel.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;

      AuthUtil.saveAuthConfig(
        authConfigModel,
        widget._wallet,
        authType: widget._authType,
      );
    }
    if (mounted) setState(() {});
  }
}

enum AuthType { pay, exchange }
