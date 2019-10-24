import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/business/login/reset_password_bloc/bloc.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';

class ResetPasswordPage extends StatefulWidget {
  String email;

  ResetPasswordPage({this.email});

  @override
  State<StatefulWidget> createState() {
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

  ResetPasswordBloc _resetPasswordBloc = ResetPasswordBloc(UserService());

  @override
  Widget build(BuildContext context) {
    emailEditingController.text = widget.email;

    return BlocBuilder<ResetPasswordBloc, SubmitState>(
        bloc: _resetPasswordBloc,
        builder: (BuildContext context, SubmitState state) {
          var _registerButtonText = state is SubmitIngState ? "处理中" : "提交";
          Function _registerOnPress = state is SubmitIngState ? null : _submit;
          var _fieldEnable = state is SubmitIngState ? false : true;

          if (state is SubmitSuccessState) {
            Fluttertoast.showToast(msg: "修改成功");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context, true);
            });
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
//        backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "重置账户密码",
                style: TextStyle(color: Colors.white),
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
                        if (widget.email != null)
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  widget.email,
                                  style: TextStyle(
                                    color: Color(0xFF6D6D6D),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        if (widget.email == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                            child: TextFormField(
                              enabled: _fieldEnable,
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
                                  enabled: _fieldEnable,
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
                            enabled: _fieldEnable,
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
                            enabled: _fieldEnable,
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
                            onPressed: _registerOnPress,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  if (state is SubmitIngState)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Loading(
                                            indicator: BallSpinFadeLoaderIndicator(),
                                          )),
                                    ),
                                  Text(
                                    _registerButtonText,
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                  ),
                                ],
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
        });
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      print("validate success");

      String email = emailEditingController.text;
      String password = passwordEditingController.text;
      int verificationCode = int.parse(verificationCodeEditingController.text);

      _resetPasswordBloc.add(ResetPassword(email, password, verificationCode));
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
