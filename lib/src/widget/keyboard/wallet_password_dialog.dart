import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/wallet/forgot_wallet_password_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/keyboard/pay_password.dart';
import 'package:vibration/vibration.dart';

import 'keyboard_widget.dart';

typedef Future<bool> CheckPwdValid(String pwd);

class WalletPasswordDialog extends StatefulWidget {
  String title;
  final CheckPwdValid checkPwdValid;
  final bool isDoubleCheck;
  bool isFirstTime = true;

  WalletPasswordDialog({this.title, this.checkPwdValid, this.isDoubleCheck = false});

  @override
  BaseState<StatefulWidget> createState() {
    return _WalletPasswordDialogState();
  }
}

class _WalletPasswordDialogState extends BaseState<WalletPasswordDialog> {
  Wallet wallet;
  final TextEditingController _pinPutController = TextEditingController();
  bool _pwdInvalid = false;
  String firstInputPassword = "";

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onCreated() {
    super.onCreated();
    if (!widget.isDoubleCheck) {
      wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
    }
    widget.title = "请输入支付密码";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return;
      },
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Container(
                  height: 232,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        margin: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  widget.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 8.0,
                              ),
                              child: PinInputTextField(
                                enabled: false,
                                autoFocus: false,
                                pinLength: 6,
                                decoration: BoxTightDecoration(
                                  strokeColor: DefaultColors.color999,
                                  strokeWidth: 0.5,
                                  obscureStyle: ObscureStyle(
                                    isTextObscure: true,
                                    obscureText: '●',
                                  ),
                                ),
                                controller: _pinPutController,
                                textInputAction: TextInputAction.done,
                                /*onChanged: (pin) async {
                                  if (pin.length == 6) {
                                    var result = await widget.checkPwdValid(pin);
                                    if (result) {
                                      Navigator.of(context).pop(pin);
                                    } else {
                                      setState(() {
                                        setState(() {
                                          _pwdInvalid = true;
                                        });
                                        _pinPutController.clear();
                                      });
                                      if (await Vibration.hasVibrator()) {
                                        Vibration.vibrate();
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      _pwdInvalid = false;
                                    });
                                  }
                                },*/
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                if (_pwdInvalid)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      widget.isDoubleCheck ? '两次输入密码不一致' : '您的密码有误',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                Spacer(),
                                if (!widget.isDoubleCheck)
                                  InkWell(
                                  child: Text(
                                      '忘记密码',
                                      style: TextStyle(color: HexColor('#FF1F81FF'), fontSize: 14),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ForgotWalletPasswordPage(),
                                          ));
                                    },
                                  ),
                                SizedBox(
                                  width: 8.0,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            if (!widget.isDoubleCheck)
                              Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'res/drawable/ic_wallet.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      wallet.keystore.name,
                                      style: TextStyle(
                                        color: HexColor('#FF999999'),
                                      ),
                                    )
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Image.asset(
                              'res/drawable/ic_password_close.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                      if (!widget.isDoubleCheck)
                        Positioned(
                          right: 14,
                          top: 14,
                          child: GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Image.asset(
                                'res/drawable/ic_password_fingerprint.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
            MyKeyboard(_onKeyDown)
          ],
        ),
      ),
    );
  }

  void _onKeyDown(KeyEvent data) async {
    var inputText = _pinPutController.text;
    if (data.isDelete()) {
      if (inputText.length > 0) {
        inputText = inputText.substring(0, inputText.length - 1);
      } else {
        return;
      }
    } else if (inputText.length < 5) {
      inputText += data.key;
    } else {
      inputText += data.key;
      if (widget.isDoubleCheck) {
        if (widget.isFirstTime) {
          setState(() {
            widget.isFirstTime = false;
            firstInputPassword = inputText;
            widget.title = "请再次确认支付密码";
            _pinPutController.clear();
          });
        } else {
          print("password3   $firstInputPassword  $inputText");
          if (firstInputPassword == inputText) {
            Navigator.of(context).pop(inputText);
          } else {
            setState(() {
              firstInputPassword = "";
              widget.isFirstTime = true;
              _pwdInvalid = true;
              widget.title = "请输入支付密码";
              _pinPutController.clear();
            });
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate();
            }
          }
        }
        return;
      } else {
        var result = await widget.checkPwdValid(inputText);
        if (result) {
          Navigator.of(context).pop(inputText);
        } else {
          setState(() {
            _pwdInvalid = true;
            _pinPutController.clear();
          });
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate();
          }
        }
        return;
      }
    }

    setState(() {
      _pwdInvalid = false;
      _pinPutController.text = inputText;
    });
  }
}
