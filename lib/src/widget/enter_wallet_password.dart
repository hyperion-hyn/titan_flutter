import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/utils/validator_util.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class EnterWalletPasswordWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EnterWalletPasswordState();
  }
}

class EnterWalletPasswordState extends State<EnterWalletPasswordWidget> {
  int _countdownTime = 0;
  Timer _timer;

  String walletEditErrorMsg;

  final _formKey = GlobalKey<FormState>();

  TextEditingController passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
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
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        S.of(context).wallet_password_label,
                        style: TextStyle(
                            color: HexColor("#093956"),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: HexColor('#FFF2F2F2')),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
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
                              keyboardType: TextInputType.emailAddress,
                              obscureText: true,
                              decoration: InputDecoration.collapsed(
                                hintText: S
                                    .of(context)
                                    .please_input_wallet_password_hint,
                                hintStyle: TextStyle(
                                  color: HexColor('#FF999999'),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (walletEditErrorMsg != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  walletEditErrorMsg,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
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
                              String password = passwordEditingController.text;
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
                          height: 40,
                        ),
                      ),
                    )
                  ])),
        ),
      ),
    );
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
