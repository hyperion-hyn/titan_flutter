import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/fund_token.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';
import 'package:titan/src/utils/md5_util.dart';

import 'package:titan/src/basic/http/http_exception.dart';

class EnterFundPasswordWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EnterFundPasswordState();
  }
}

class EnterFundPasswordState extends State<EnterFundPasswordWidget> {
  int _countdownTime = 0;
  Timer _timer;

  String email;

  UserService _userService = UserService();

  String fundEditErrorMsg = null;

  final _formKey = GlobalKey<FormState>();

  TextEditingController fundPasswordEditingController = TextEditingController();

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
                      S.of(context).safety_verify,
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
                  S.of(context).fund_password,
                  style: TextStyle(color: HexColor("#093956"), fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (!ValidatorUtil.validatePassword(value)) {
                    return S.of(context).fund_password_format_error_message;
                  } else {
                    return null;
                  }
                },
                controller: fundPasswordEditingController,
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                decoration:
                    InputDecoration(hintText: S.of(context).please_input_fund_pwd_hint, errorText: fundEditErrorMsg != null ? fundEditErrorMsg : null),
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
                              String fundPassword = fundPasswordEditingController.text;
                              fundEditErrorMsg = null;

                              try {
                                FundToken fundToken =
                                    await _userService.getFundToken(Md5Util.generateMd5(fundPassword));
                                Navigator.pop(context, fundToken.token);
                              } on HttpResponseCodeNotSuccess catch (_) {
                                if (_.code == ERROR_FUND_PASSWORD.code) {
                                  fundEditErrorMsg = ERROR_FUND_PASSWORD.message;
                                  setState(() {});
                                  return;
                                } else {
                                  throw _;
                                }
                              }
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
