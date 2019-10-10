import 'package:flutter/material.dart';
import 'package:titan/src/business/login/login_event.dart';
import 'package:titan/src/business/login/reset_password_page.dart';
import 'package:titan/src/business/me/user_info_state.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

class PersonalSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PersonalSettingsState();
  }
}

class _PersonalSettingsState extends UserState<PersonalSettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("个人信息"),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.black12), shape: BoxShape.rectangle),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.email,
                    color: Colors.black54,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LOGIN_USER_INFO.email,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          _buildMemuBar("修改密码", ExtendsIconFont.lock, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
          }),
          SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: OutlineButton(
              borderSide: BorderSide(width: 1),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                eventBus.fire(ReloginEvent());
              },
              child: Text("登出"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMemuBar(String title, IconData iconData, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), shape: BoxShape.rectangle),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                iconData,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.black54,
            )
          ],
        ),
      ),
    );
  }
}
