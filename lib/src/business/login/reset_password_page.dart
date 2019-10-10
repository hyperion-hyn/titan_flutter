import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ResetPageState();
  }
}

class _ResetPageState extends State<ResetPasswordPage> {
  UserService _userService = UserService();
  Timer _timer;
  int _countdownTime = 0;
  String validateEmailErrMsg = null;

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController verificationCodeEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 32, left: 8, right: 8),
                  child: Text(
                    "重置密码",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (!ValidatorUtil.isEmail(value)) {
                        return "邮箱格式有误，请输入正确的邮箱";
                      } else {
                        return null;
                      }
                    },
                    controller: emailEditingController,
                    decoration: InputDecoration(
                        hintText: "请输入邮箱", errorText: validateEmailErrMsg != null ? validateEmailErrMsg : null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (!ValidatorUtil.validatePassword(value)) {
                        return "密码格式有误，请输入最少6位";
                      } else {
                        return null;
                      }
                    },
                    controller: passwordEditingController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "请输入新密码"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (!ValidatorUtil.validateCode(6, value)) {
                        return "请输入6位验证码";
                      } else {
                        return null;
                      }
                    },
                    controller: verificationCodeEditingController,
                    decoration: InputDecoration(
                        hintText: "验证码",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FlatButton(
                              padding: EdgeInsets.all(8),
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onPressed: () {
                                print("onPressed");
                                if (_countdownTime == 0 && validateEmail()) {
                                  _userService.verification(emailEditingController.text);
                                  setState(() {
                                    _countdownTime = 60;
                                  });
                                  //开始倒计时
                                  startCountdownTimer();
                                }
                              },
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                _countdownTime > 0 ? '$_countdownTime秒后重新获取' : '获取验证码',
                              )),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () {
                      _submit();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "提交",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      print("validate success");

      String email = emailEditingController.text;
      String password = passwordEditingController.text;
      int verificationCode = int.parse(verificationCodeEditingController.text);

      try {
        await _userService.resetPassword(email, password, verificationCode);
        Fluttertoast.showToast(msg: "修改成功");
        Navigator.pop(context, true);
      } catch (_) {
        print(_);
        Fluttertoast.showToast(msg: "系统错误");
      }
    }
  }

  bool validateEmail() {
    if (ValidatorUtil.isEmail(emailEditingController.text)) {
      validateEmailErrMsg = null;
      setState(() {});
      return true;
    } else {
      validateEmailErrMsg = "请输入正确的邮箱";
      setState(() {});
      return false;
    }
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
