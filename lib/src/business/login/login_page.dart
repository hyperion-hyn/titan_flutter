import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/business/login/register_page.dart';
import 'package:titan/src/business/login/reset_password_page.dart';
import 'package:titan/src/business/me/model/user_token.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';
import 'package:titan/src/global.dart';

import 'login_event.dart';

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

  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 32, left: 8, right: 8),
                    child: Text(
                      "账号密码登陆",
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
                        hintText: "请输入邮箱",
                      ),
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
                      decoration: InputDecoration(
                        hintText: "请输入密码",
                      ),
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
                          "登录",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                        ),
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
                            "忘记密码",
                            style: TextStyle(color: Colors.grey[700], fontSize: 16),
                          ),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 180),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Text("注册账号")],
                      ),
                    ),
                  ),
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

      try {
        UserToken userToken = await _userService.login(email, password);
        if (userToken == null) {
          Fluttertoast.showToast(msg: "用户名或密码错误");
        } else {
          Fluttertoast.showToast(msg: "登录成功");
          LOGIN_STATUS = 2;
          eventBus.fire(LoginSuccessEvent());
        }
      } catch (_) {
        print(_);
        Fluttertoast.showToast(msg: "用户名或密码错误");
      }
    }
  }
}
