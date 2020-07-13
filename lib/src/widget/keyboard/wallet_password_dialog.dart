import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/SetBioAuthPage.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/wallet/forgot_wallet_password_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/keyboard/pay_password.dart';
import 'package:vibration/vibration.dart';

import 'keyboard_widget.dart';

typedef Future<bool> CheckPwdValid(String pwd);

class WalletPasswordDialog extends StatefulWidget {
  String title;
  final CheckPwdValid checkPwdValid;
  final bool isDoubleCheck;
  final bool isShowBioAuthIcon;
  bool isFirstTime = true;

  WalletPasswordDialog({
    this.title,
    @required this.checkPwdValid,
    this.isDoubleCheck = false,
    this.isShowBioAuthIcon = true,
  });

  @override
  BaseState<StatefulWidget> createState() {
    return _WalletPasswordDialogState();
  }
}

class _WalletPasswordDialogState extends BaseState<WalletPasswordDialog> {
  Wallet wallet;
  final TextEditingController _pinPutController = TextEditingController();
  bool _isHideLayout = false;
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
      widget.title ??= S.of(context).input_payment_password;
    }else{
      widget.title ??= S.of(context).setting_payment_password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return;
      },
      child: _isHideLayout
          ? SizedBox()
          : Material(
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
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
                                            widget.isDoubleCheck
                                                ? S.of(context).double_check_password_error
                                                : S.of(context).fund_password_error,
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      Spacer(),
                                      if (!widget.isDoubleCheck)
                                        InkWell(
                                          child: Text(
                                            S.of(context).forgot_password,
                                            style: TextStyle(
                                                color: HexColor('#FF1F81FF'),
                                                fontSize: 14),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ForgotWalletPasswordPage(),
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
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
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
                            if (!widget.isDoubleCheck &&
                                widget.isShowBioAuthIcon)
                              Positioned(
                                right: 16,
                                top: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    _goToBioAuthSettingPage();
                                  },
                                  child: _bioAuthIcon(),
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
            widget.title = S.of(context).input_confirm_wallet_password_hint;
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
              widget.title = S.of(context).input_payment_password;
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

  _bioAuthIcon() {
    if (AuthInheritedModel.of(
      context,
      aspect: AuthAspect.config,
    ).bioAuthAvailable) {
      if (AuthInheritedModel.of(
            context,
            aspect: AuthAspect.config,
          ).availableBioMetricType ==
          BiometricType.face) {
        return Image.asset(
          'res/drawable/ic_face_id.png',
          width: 20,
          height: 20,
        );
      } else if (AuthInheritedModel.of(
            context,
            aspect: AuthAspect.config,
          ).availableBioMetricType ==
          BiometricType.fingerprint) {
        return Image.asset(
          'res/drawable/ic_fingerprint.png',
          width: 20,
          height: 20,
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  _goToBioAuthSettingPage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SetBioAuthPage()));
    setState(() {
      _isHideLayout = true;
    });

    ///Add delay to return more smoothly, in case some devices show too fast
    Future.delayed(Duration(milliseconds: 200), () async {
      ///Show password dialog again
      var pwd = await UiUtil.showWalletPasswordDialogV2(
        context,
        wallet,
      );
      Navigator.of(context).pop(pwd);
    });
  }
}
