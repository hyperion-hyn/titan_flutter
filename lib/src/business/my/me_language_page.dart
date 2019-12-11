import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';

class MeLanguagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguageState();
  }
}

class _LanguageState extends State<MeLanguagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).language,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(padding: EdgeInsets.symmetric(horizontal: 0), children: <Widget>[
        SizedBox(
          height: 4,
        ),
        _buildInfoContainer(label: '简体中文', code: 'zh', locale: Locale("zh", "CN")),
        _divider(),
        _buildInfoContainer(label: '한국어', code: 'ko', locale: Locale("ko")),
        _divider(),
        _buildInfoContainer(label: 'English', code: 'en', locale: Locale("en")),
        _divider(),
      ]),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.0,
        color: HexColor('#D7D7D7'),
      ),
    );
  }

  Widget _buildInfoContainer({String label, String code, Locale locale}) {
    return InkWell(
      onTap: () {
        switchLanguage(code, locale);
      },
      child: Container(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
              child: Text(
                label,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16),
              ),
            ),
            Spacer(),
            Visibility(
              visible: appLocale.languageCode == code,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
                child: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void switchLanguage(String code, Locale locale) {
    print("[Language] --> switchLanguage, code:${code}");

    saveLocale(locale);
    localeChange(locale);
  }

  Future saveLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsKey.appLanguageCode, locale.languageCode);
    prefs.setString(PrefsKey.appCountryCode, locale.countryCode);
  }
}
