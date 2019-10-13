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
  TextEditingController confirmPasswordEditingController = TextEditingController();
  TextEditingController verificationCodeEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "重置账户密码",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        "邮箱",
                        style: TextStyle(
                          color: Color(0xFF6D6D6D),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                        errorText: validateEmailErrMsg != null ? validateEmailErrMsg : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "验证码",
                        style: TextStyle(
                          color: Color(0xFF6D6D6D),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (!ValidatorUtil.validateCode(6, value)) {
                                return "请输入6位验证码";
                              } else {
                                return null;
                              }
                            },
                            controller: verificationCodeEditingController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                          width: 36,
                        ),
                        GestureDetector(
                          onTap: () {
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
                          child: Text(
                            _countdownTime > 0 ? '重新获取 $_countdownTime' : '发送验证码',
                            style: TextStyle(
                              color: _countdownTime > 0 ? Color(0xFF9B9B9B) : Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "账户新密码",
                        style: TextStyle(
                          color: Color(0xFF6D6D6D),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "确认新密码",
                        style: TextStyle(
                          color: Color(0xFF6D6D6D),
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (!ValidatorUtil.validatePassword(value)) {
                          return "密码格式有误，请输入最少6位";
                        } else {
                          return null;
                        }
                      },
                      controller: confirmPasswordEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    constraints: BoxConstraints.expand(height: 48),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: () {
                        _submit();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "提交",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
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
