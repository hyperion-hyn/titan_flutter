import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/business/login/register_page.dart';
import 'package:titan/src/business/login/reset_password_page.dart';
import 'package:titan/src/business/me/model/user_token.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/md5_util.dart';

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
                          "邮箱",
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
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Color(0xFFB7B7B7))),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            hintText: "请输入邮箱",
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
                          "密码",
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
                          hintText: "请输入密码",
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
                              "忘记密码",
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
                        onPressed: () {
                          _submit();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "登录",
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "注册账号",
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
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      print("validate success");

      String email = emailEditingController.text;
      String password = passwordEditingController.text;

      try {
        UserToken userToken = await _userService.login(email, Md5Util.generateMd5(password));
        if (userToken == null) {
          Fluttertoast.showToast(msg: "系统错误");
        } else {
          Fluttertoast.showToast(msg: "登录成功");
          LOGIN_STATUS = 2;
          eventBus.fire(LoginSuccessEvent());
        }
      } on HttpResponseCodeNotSuccess catch (_) {
        if (_.code == ERROR_LOGIN.code) {
          Fluttertoast.showToast(msg: "用户名或密码错误");
          print(_);
        }
      }
    }
  }
}
