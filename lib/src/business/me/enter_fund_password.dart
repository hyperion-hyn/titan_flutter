import 'dart:async';

import 'package:flutter/material.dart';
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
    return Form(
      key: _formKey,
      child: Container(
          padding: EdgeInsets.all(16),
          child:
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    "安全验证",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(padding: EdgeInsets.all(4), child: Text("取消")))
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "资金密码",
                style: TextStyle(color: HexColor("#093956"), fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              validator: (value) {
                if (!ValidatorUtil.validatePassword(value)) {
                  return "密码格式有误，请输入最少6位";
                } else {
                  return null;
                }
              },
              controller: fundPasswordEditingController,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  InputDecoration(hintText: "请输入资金密码", errorText: fundEditErrorMsg != null ? fundEditErrorMsg : null),
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
                              FundToken fundToken = await _userService.getFundToken(Md5Util.generateMd5(fundPassword));
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
                          "确认",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ])),
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
