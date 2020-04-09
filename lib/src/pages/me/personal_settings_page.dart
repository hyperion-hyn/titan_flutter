import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/root_page_control_component/bloc/bloc.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/login/login_bloc/bloc.dart';
import 'package:titan/src/pages/login/login_page.dart';
import 'package:titan/src/pages/login/reset_fund_password_page.dart';
import 'package:titan/src/pages/login/reset_password_page.dart';
import 'package:titan/src/pages/me/components/account/account_component.dart';
import 'package:titan/src/pages/me/components/account/bloc/account_event.dart';
import 'package:titan/src/pages/me/model/user_info.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/extension/navigator_ext.dart';

import 'components/account/bloc/account_bloc.dart';

class PersonalSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PersonalSettingsState();
  }
}

class _PersonalSettingsState extends State<PersonalSettingsPage> {

  @override
  Widget build(BuildContext context) {
    UserInfo userInfo = AccountInheritedModel.of(context, aspect: AccountAspect.userInfo).userInfo;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Colors.white,
        title: Text(
          S.of(context).personal_information,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Image.asset(
                    "res/drawable/email_icon.png",
                    width: 36,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).email_label,
                      style: TextStyle(color: Color(0xFF333333), fontSize: 16),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      userInfo?.email ?? '',
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _buildMemuBar(S.of(context).modify_account_password, ExtendsIconFont.lock, () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ResetPasswordPage(email: userInfo.email)));
                }),
                Divider(),
                _buildMemuBar(S.of(context).modify_fund_password, ExtendsIconFont.lock, () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ResetFundPasswordPage(email: userInfo.email)));
                }),
              ],
            ),
          ),
//          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: RaisedButton(
              elevation: 1,
              color: Color(0xFFBCC1C7),
              onPressed: () {
                Navigator.of(context).popUntilRouteName(Routes.root);
                BlocProvider.of<AccountBloc>(context).add(LogoutUserEvent());
                BlocProvider.of<RootPageControlBloc>(context).add(SetRootPageEvent(
                    page: BlocProvider<LoginBloc>(create: (context) => LoginBloc(), child: LoginPage())));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                child: SizedBox(
                    height: 40,
                    width: 192,
                    child: Center(
                        child: Text(
                      S.of(context).login_out,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemuBar(String title, IconData iconData, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: Text(
                    title,
                    style: TextStyle(color: Color(0xFF333333), fontSize: 15),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
