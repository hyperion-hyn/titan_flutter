import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';
import 'package:titan/src/business/login/register_page.dart';
import 'package:titan/src/business/login/reset_password_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import 'login_bloc/bloc.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  LoginBloc _loginBloc = LoginBloc(UserService());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, SubmitState>(
      bloc: _loginBloc,
      builder: (BuildContext context, SubmitState state) {
        var loginButtonText = state is SubmitIngState ? S.of(context).logining : S.of(context).login;
        Function loginOnPress = state is SubmitIngState ? null : _submit;
        var fieldEnable = state is SubmitIngState ? false : true;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Stack(
            children: <Widget>[
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          child: Image.asset(
                            "res/drawable/map_rich_application.png",
                            width: 32,
                            height: 128,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              ExtendsIconFont.email,
                              color: Color(0xFF6D6D6D),
                              size: 18,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              S.of(context).email_label,
                              style: TextStyle(
                                color: Color(0xFF6D6D6D),
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: TextFormField(
                            enabled: fieldEnable,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (!ValidatorUtil.isEmail(value)) {
                                return S.of(context).email_format_error_hint;
                              } else {
                                return null;
                              }
                            },
                            controller: emailEditingController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Color(0xFFB7B7B7))),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                hintText: S.of(context).please_input_email_hint,
                                hintStyle: TextStyle(color: Color(0XFFD7D7D7))),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              ExtendsIconFont.lock_outline,
                              color: Color(0xFF6D6D6D),
                              size: 20,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              S.of(context).password_label,
                              style: TextStyle(
                                color: Color(0xFF6D6D6D),
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: TextFormField(
                            enabled: fieldEnable,
                            keyboardType: TextInputType.visiblePassword,
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
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              hintText: S.of(context).please_input_password_hint,
                              hintStyle: TextStyle(color: Color(0XFFD7D7D7)),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                          },
                          child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  S.of(context).forget_password,
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                                ),
                              )),
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
                            onPressed: loginOnPress,
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
                                    loginButtonText,
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  S.of(context).register_account,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      print("validate success");

      String email = emailEditingController.text;
      String password = passwordEditingController.text;

      _loginBloc.add(Login(email, password));
    }
  }
}
