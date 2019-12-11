import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/global.dart';
import 'package:titan/app_locale_config.dart';

class MeLanguagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguageState();
  }
}

class _LanguageState extends State<MeLanguagePage> {

  String languageCode = "en";

  @override
  void initState() {

    super.initState();

    languageCode = locale_config.languageCode;
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
      body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 0),
          children: <Widget>[
            SizedBox(
              height: 4,
            ),
            _buildInfoContainer(label: '简体中文', code: 'zh'),
            _divider(),
            _buildInfoContainer(label: '한국어', code: 'ko'),
            _divider(),
            _buildInfoContainer(label: 'English', code: 'en'),
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

  Widget _buildInfoContainer({String label, String code}) {
    return InkWell(
      onTap: () {
        switchLanguage(code);
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
              visible: languageCode == code,
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

  void switchLanguage(String code) {
    print("[Language] --> switchLanguage, code:${code}");

    setState(() {
        languageCode = code;

        var index = 0;
        switch (code) {
          case 'zh':
            index = 1;
            break;

          case 'ko':
            index = 2;
            break;

          case 'en':
            index = 3;
            break;
        }
        AppLocaleConfig.gCurrentThemeIndex = index;

    });
  }

}

