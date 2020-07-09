import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/SetBioAuthPage.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/wallet/forgot_wallet_password_page.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/validator_util.dart';
import 'package:titan/src/widget/click_oval_button.dart';

import 'keyboard/wallet_password_dialog.dart';

class EnterWalletPasswordWidget extends StatefulWidget {
  final bool useDigits;
  final CheckPwdValid onPwdSubmitted;
  final bool isShowBioAuthIcon;

  EnterWalletPasswordWidget({
    this.useDigits = false,
    this.onPwdSubmitted,
    this.isShowBioAuthIcon = true,
  });

  @override
  State<StatefulWidget> createState() {
    return EnterWalletPasswordState();
  }
}

class EnterWalletPasswordState extends BaseState<EnterWalletPasswordWidget> {
  int _countdownTime = 0;
  Timer _timer;

  String walletEditErrorMsg;

  final _formKey = GlobalKey<FormState>();

  TextEditingController passwordEditingController = TextEditingController();

  bool _isHideLayout = false;
  Wallet wallet;

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
  }

  @override
  Widget build(BuildContext context) {
    return _isHideLayout
        ? SizedBox()
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Container(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  S.of(context).safety_verification,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  S.of(context).wallet_password_label,
                                  style: TextStyle(
                                      color: HexColor("#093956"),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextFormField(
                                inputFormatters: [
//                                if (widget.useDigits)
//                                  LengthLimitingTextInputFormatter(6),
                                ],
                                validator: (value) {
                                  if (!ValidatorUtil.validatePassword(value)) {
                                    return S
                                        .of(context)
                                        .input_confirm_wallet_password_hint;
                                  } else {
                                    return null;
                                  }
                                },
                                controller: passwordEditingController,
//                              keyboardType: widget.useDigits
//                                  ? TextInputType.number
//                                  : TextInputType.emailAddress,
                                keyboardType: TextInputType.emailAddress,
                                obscureText: true,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                  filled: true,
                                  fillColor: HexColor('#FFF2F2F2'),
                                  hintText: S
                                      .of(context)
                                      .please_input_wallet_password_hint,
                                  errorText: walletEditErrorMsg != null
                                      ? walletEditErrorMsg
                                      : null,
                                  hintStyle: TextStyle(
                                    color: HexColor('#FF999999'),
                                    fontSize: 14,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: HexColor('#FFF2F2F2'),
                                      width: 0.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: HexColor('#FFF2F2F2'),
                                      width: 0.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: HexColor('#FFF2F2F2'),
                                      width: 0.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Spacer(),
                                  InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Text(
                                        '忘记密码',
                                        style: TextStyle(
                                            color: HexColor('#FF1F81FF')),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ForgotWalletPasswordPage(),
                                          ));
                                    },
                                  )
                                ],
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 32),
                                  child: ClickOvalButton(
                                    S.of(context).confirm,
                                    () {
                                      if (ValidatorUtil.validatePassword(
                                          passwordEditingController.text)) {
                                        String password =
                                            passwordEditingController.text;
                                        Navigator.pop(context, password);
                                      } else {
                                        setState(() {
                                          walletEditErrorMsg = S
                                              .of(context)
                                              .input_confirm_wallet_password_hint;
                                        });
                                      }
                                    },
                                    width: 200,
                                    height: 45,
                                  ),
                                ),
                              )
                            ])),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: InkWell(
                    child: Image.asset(
                      'res/drawable/ic_dialog_close.png',
                      width: 18,
                      height: 18,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                if (widget.isShowBioAuthIcon)
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
          );
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

    ///Show password dialog again
    var pwd = await UiUtil.showWalletPasswordDialogV2(context, wallet,
        onCheckPwdValid: (pwd) {
      return WalletUtil.checkPwdValid(context, pwd);
    });
    Navigator.of(context).pop(pwd);
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _timer.cancel();
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}
