import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gesture_unlock/lock_pattern.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/lock_patten_auth.dart';

class AuthDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthDialogState();
  }
}

class _AuthDialogState extends State<AuthDialog> {
  final LocalAuthentication auth = LocalAuthentication();

  ///When used up remain quick-auth times, use password to authorize.
  bool _usePassword = false;
  int _quickAuthMaxCount = 3;
  int _quickAuthRemainCount;

  ///Check available biometrics
  List<BiometricType> _availableBiometrics = List();

  bool _authorized = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _quickAuthRemainCount = _quickAuthMaxCount;

    _getAvailableBiometrics();
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '钱包授权登陆',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _authorized ? _onAuthorized() : _authLayout(),
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

  _onAuthorized() {
    return Container(
      width: 300,
      height: 300,
      child: Center(
        child: Text('验证成功'),
      ),
    );
  }

  _authLayout() {
    return Column(
      children: <Widget>[
        _usePassword
            ? Container(
                child: EnterWalletPasswordWidget(),
                height: 250,
              )
            : _quickAuthWidget(),
        !_usePassword && _quickAuthRemainCount < _quickAuthMaxCount
            ? _quickAuthRemainCountHint()
            : SizedBox(),
      ],
    );
  }

  _quickAuthWidget() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return _faceAuthWidget();
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return _fingerprintAuthWidget();
    } else {
      return LockPatternVerify(
        password: '1236',
        onVerifyFailed: () {
          setState(() {
            _quickAuthRemainCount--;
            if (_quickAuthRemainCount == 0) {
              _usePassword = true;
            }
          });
        },
        onVerifyPassed: () {
          Fluttertoast.showToast(msg: 'Verify successful');
        },
      );
    }
  }

  _faceAuthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 50,
          height: 50,
          color: Colors.amber,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '钱包的Face ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text('请验证已有的Face ID'),
        InkWell(
          onTap: () {
            _authenticate();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '重新验证',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        )
      ],
    );
  }

  _fingerprintAuthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 50,
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '钱包的Touch ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text('请验证已有的指纹')
      ],
    );
  }

  _quickAuthRemainCountHint() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: <Widget>[
          Text('识别失败，剩余$_quickAuthRemainCount次'),
          SizedBox(
            width: 8,
          ),
          InkWell(
            child: Text(
              '取消',
              style: TextStyle(color: Colors.blue),
            ),
            onTap: () {
              setState(() {
                _usePassword = true;
              });
            },
          )
        ],
      ),
    );
  }

  _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          useErrorDialogs: true,
          stickyAuth: true,
          localizedReason: 'Use your face or fingerprint to authorize.');
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
    if (!mounted) return;

    if (!authenticated) {
      _quickAuthRemainCount--;
      if (_quickAuthRemainCount == 0) {
        setState(() {
          _usePassword = true;
        });
      }
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = authenticated;
    });
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
      if (!_usePassword) {
        _authenticate();
      }
    });
  }
}
