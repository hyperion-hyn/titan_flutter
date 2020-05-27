import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/utils/validator_util.dart';

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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
            child:
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Text(
                      S.of(context).safety_verification,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(padding: EdgeInsets.all(4), child: Text(S.of(context).cancel)))
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  S.of(context).wallet_password_label,
                  style: TextStyle(color: HexColor("#093956"), fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (!ValidatorUtil.validatePassword(value)) {
                    return S.of(context).input_confirm_wallet_password_hint;
                  } else {
                    return null;
                  }
                },
                controller: passwordEditingController,
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: S.of(context).please_input_wallet_password_hint, errorText: walletEditErrorMsg != null ? walletEditErrorMsg : null),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: SizedBox(
                        height: 42,
                        child: RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              String password = passwordEditingController.text;
                              Navigator.pop(context, password);
                            }
                          },
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            S.of(context).confirm,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ])),
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
