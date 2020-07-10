import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'auth_component.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';

class SetBioAuthPage extends StatefulWidget {
  SetBioAuthPage();

  @override
  State<StatefulWidget> createState() {
    return _SetBioAuthPageState();
  }
}

class _SetBioAuthPageState extends BaseState<SetBioAuthPage> {
  Wallet _wallet;
  final LocalAuthentication auth = LocalAuthentication();
  List<BiometricType> _availableBiometrics = List();

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    _wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
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
          '免密支付',
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
        title: Text('面容识别'),
        value: AuthInheritedModel.of(
          context,
          aspect: AuthAspect.config,
        ).authConfigModel.useFace,
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
        title: Text('指纹识别'),
        value: AuthInheritedModel.of(
          context,
          aspect: AuthAspect.config,
        ).authConfigModel.useFingerprint,
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
                '免密支付介绍',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                '免密支付将您的钱包密码通过安全加密算法存储至手机设备的Keychain / KeyStore中，交易时调用生物识别（指纹或面容）鉴权，快速完成支付与签名。',
                style: TextStyle(
                  height: 1.7,
                  fontSize: 13,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                '开启免密支付后，请妥善备份密码。如果忘记密码，可以通过导入助计词 / 私钥，重新设置密码',
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
                  '风险提示',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text(
                '请了解你的手机设备生物识别的安全等级\n大额资产，请勿开启免密支付\n公共手机，请勿开启免密支付\n',
                style: TextStyle(
                  height: 1.8,
                  fontSize: 13,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '免责声明',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text(
                '手机厂商的生物识别技术安全等级各有差异，我们提醒用户谨慎使用该便捷功能。使用过程中出现任何生物识别技术漏洞引发的资产风险，本软件不承担法律责任。',
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
        _wallet,
        onCheckPwdValid: (String password) async {
          return WalletUtil.checkPwdValid(context, password);
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
            _wallet,
            password,
          );

          ///
          BlocProvider.of<AuthBloc>(context).add(
            SetBioAuthEvent(
              biometricType,
              true,
              _wallet,
            ),
          );
          Fluttertoast.showToast(msg: '免密支付开启成功');
        } else {
          Fluttertoast.showToast(msg: '免密支付开启失败');
        }
      } else {
        Fluttertoast.showToast(msg: '免密支付开启失败');
      }
    } else {
      BlocProvider.of<AuthBloc>(context).add(SetBioAuthEvent(
        biometricType,
        value,
        _wallet,
      ));
    }
    if (mounted) setState(() {});
  }
}
