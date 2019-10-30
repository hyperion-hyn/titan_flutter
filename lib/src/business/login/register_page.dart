import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:titan/src/business/login/register_bloc/bloc.dart';
import 'package:titan/src/business/login/register_bloc/register_state.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  UserService _userService = UserService();
  Timer _timer;
  int _countdownTime = 0;

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController safetyPasswordEditingController = TextEditingController();
  TextEditingController invitationCodeEditingController = TextEditingController();
  TextEditingController verificationCodeEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String validateEmailErrMsg = null;

  RegisterBloc _registerBloc = RegisterBloc(UserService());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
        bloc: _registerBloc,
        builder: (BuildContext context, RegisterState state) {
          var _registerButtonText = state is SubmitIngState ? "处理中" : "注册";
          Function _registerOnPress = state is SubmitIngState ? null : _submit;
          var _fieldEnable = state is SubmitIngState ? false : true;

          if (state is SubmitSuccessState) {
            Fluttertoast.showToast(msg: "注册成功");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context, true);
              return;
            });
            _registerBloc.add(ResetToInit());
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "注册",
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
                              "注册邮箱",
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
                            keyboardType: TextInputType.emailAddress,
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
                              "邀请码",
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
                              validator: (value) {
                                if (!ValidatorUtil.validateCode(6, value)) {
                                  return "请输入6位邀请码";
                                } else {
                                  return null;
                                }
                              },
                              controller: invitationCodeEditingController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              keyboardType: TextInputType.text),
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "账户密码",
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
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "资金安全密码",
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
                            validator: (value) {
                              if (!ValidatorUtil.validatePassword(value)) {
                                return "密码格式有误，请输入最少6位";
                              } else {
                                return null;
                              }
                            },
                            controller: safetyPasswordEditingController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            keyboardType: TextInputType.visiblePassword,
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
      String fundPassword = safetyPasswordEditingController.text;
      String invitationCode = invitationCodeEditingController.text;
      int verificationCode = int.parse(verificationCodeEditingController.text);
      _registerBloc.add(Register(email, password, fundPassword, invitationCode, verificationCode));
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
