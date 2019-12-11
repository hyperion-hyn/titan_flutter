import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'me_language_page.dart';

class MeSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeSettingState();
  }
}

class _MeSettingState extends State<MeSettingPage> {
  int checkInCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var languageName = Const.LANGUAGE_NAME_MAP["${appLocale.languageCode}_${appLocale.countryCode ?? ""}"];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).setting,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16),
        children: <Widget>[
          _buildMemuBar(S.of(context).language, languageName, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MeLanguagePage()));
          }),
        ],
      ),
    );
  }

  Widget _buildMemuBar(String title, String subTitle, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
              child: Text(
                title,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(
                subTitle,
                style: TextStyle(color: HexColor("#AAAAAA"), fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 15, 14, 14),
              child: Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
