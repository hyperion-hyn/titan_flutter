import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/login/register_bloc/bloc.dart';
import 'package:titan/src/pages/login/register_bloc/register_state.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/pages/me/util/validator_util.dart';

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

  String _validateEmailErrMsg;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, AbsRegisterState>(
      listener: (context, state) {
        if (state is RegisterState) {
          if (state.status == Status.success) {
            Fluttertoast.showToast(msg: S.of(context).register_success);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context, true);
            });
          }
        }
      },
      child: BlocBuilder<RegisterBloc, AbsRegisterState>(
          bloc: BlocProvider.of<RegisterBloc>(context),
          builder: (BuildContext context, AbsRegisterState state) {
            var isLoading = (state is RegisterState) && state.status == Status.loading;
            var _registerButtonText = isLoading ? S.of(context).processing : S.of(context).register;
            Function _registerOnPress = isLoading ? null : _submit;
            var _fieldEnable = isLoading ? false : true;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white),
                title: Text(
                  S.of(context).register,
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
                                S.of(context).register_email,
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
                                  return S.of(context).email_format_error_hint;
                                } else {
                                  return null;
                                }
                              },
                              controller: emailEditingController,
                              decoration: InputDecoration(
                                hintText: S.of(context).please_input_email_hint,
                                errorText: _validateEmailErrMsg != null ? _validateEmailErrMsg : null,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                S.of(context).verification_code,
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
                                        return S.of(context).please_input_verification_code;
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: verificationCodeEditingController,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).please_input_verification_code,
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
                                    _countdownTime > 0
                                        ? S.of(context).get_verification_code_again(_countdownTime.toString())
                                        : S.of(context).send_verification_code,
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
                                S.of(context).invitation_code,
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
                                    return S.of(context).please_input_invitation_code;
                                  } else {
                                    return null;
                                  }
                                },
                                controller: invitationCodeEditingController,
                                decoration: InputDecoration(
                                  hintText: S.of(context).please_input_invitation_code,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                                keyboardType: TextInputType.text),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                S.of(context).account_password,
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
                                  return S.of(context).password_format_error_message;
                                } else {
                                  return null;
                                }
                              },
                              controller: passwordEditingController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: S.of(context).password_length_error_message,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              keyboardType: TextInputType.visiblePassword,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                S.of(context).fundz_password,
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
                                  return S.of(context).fund_password_format_error_message;
                                } else {
                                  return null;
                                }
                              },
                              controller: safetyPasswordEditingController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: S.of(context).fund_password_length_error_message,
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
                                    if (isLoading)
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
          }),
    );
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      String email = emailEditingController.text;
      String password = passwordEditingController.text;
      String fundPassword = safetyPasswordEditingController.text;
      String invitationCode = invitationCodeEditingController.text;
      int verificationCode = int.parse(verificationCodeEditingController.text);

      BlocProvider.of<RegisterBloc>(context)
          .add(RegisterEvent(email, password, fundPassword, invitationCode, verificationCode));
    }
  }

  bool validateEmail() {
    if (ValidatorUtil.isEmail(emailEditingController.text)) {
      _validateEmailErrMsg = null;
      setState(() {});
      return true;
    } else {
      _validateEmailErrMsg = S.of(context).email_format_error_hint;
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
