import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gesture_unlock/lock_pattern.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/widget/gesture_unlock_widget.dart';

class AuthDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthDialogState();
  }
}

class _AuthDialogState extends State<AuthDialog> {
  final LocalAuthentication auth = LocalAuthentication();
  int _bioAuthMaxCount = 3;
  int _bioAuthRemainCount;

  bool _usePassword = false;

  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics = List();
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bioAuthRemainCount = _bioAuthMaxCount;

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
                      _usePassword
                          ? Container(
                              child: Center(
                                child: Text(
                                  '使用密码登陆',
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ),
                            )
                          : _authWidget(),
                      !_usePassword && _bioAuthRemainCount < _bioAuthMaxCount
                          ? _bioAuthRemainCountHint()
                          : SizedBox(),
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

  _authWidget() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return _faceAuthWidget();
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return _fingerprintAuthWidget();
    } else {
      return GestureUnlockWidget();
    }
    return Container(
      color: Colors.amber,
      child: Column(
        children: <Widget>[
          Text('Can check biometrics: $_canCheckBiometrics\n'),
          RaisedButton(
            child: const Text('Check biometrics'),
            onPressed: _checkBiometrics,
          ),
          Text('Available biometrics: $_availableBiometrics\n'),
          RaisedButton(
            child: const Text('Get available biometrics'),
            onPressed: _getAvailableBiometrics,
          ),
          Text('Current State: $_authorized\n'),
          RaisedButton(
            child: Text(_isAuthenticating ? 'Cancel' : 'Authenticate'),
            onPressed:
                _isAuthenticating ? _cancelAuthentication : _authenticate,
          )
        ],
      ),
    );
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

  _bioAuthRemainCountHint() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: <Widget>[
          Text('识别失败，剩余$_bioAuthRemainCount次'),
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
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
    if (!mounted) return;

    if (!authenticated) {
      _bioAuthRemainCount--;
      if (_bioAuthRemainCount == 0) {
        setState(() {
          _usePassword = true;
        });
      }
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
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
    });
  }

  Future<void> _checkBiometrics() async {
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

  void _cancelAuthentication() {
    auth.stopAuthentication();
  }
}
