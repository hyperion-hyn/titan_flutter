import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MeLanguagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanguageState();
  }
}

class _LanguageState extends State<MeLanguagePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('我的'),
    );
  }
}

//class _LanguageState extends State<MeLanguagePage> {
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  var selectedLocale = appLocale;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.white,
//      appBar: AppBar(
//        iconTheme: IconThemeData(color: Colors.white),
//        title: Text(
//          S.of(context).language,
//          style: TextStyle(color: Colors.white),
//        ),
//        centerTitle: true,
//        elevation: 0,
//        actions: <Widget>[
//          InkWell(
//            onTap: () {
//              switchLanguage(selectedLocale);
//              Navigator.pop(context);
//            },
//            child: Container(
//              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//              alignment: Alignment.centerRight,
//              child: Text(
//                S.of(context).confirm,
//                style: TextStyle(fontSize: 16, color: Colors.white),
//              ),
//            ),
//          )
//        ],
//      ),
//      body: ListView(padding: EdgeInsets.symmetric(horizontal: 0), children: <Widget>[
//        SizedBox(
//          height: 4,
//        ),
//        _buildInfoContainer(label: '简体中文', locale: Locale("zh", "CN")),
//        _divider(),
//        _buildInfoContainer(label: '한국어', locale: Locale("ko")),
//        _divider(),
//        _buildInfoContainer(label: 'English', locale: Locale("en")),
//        _divider(),
//      ]),
//    );
//  }
//
//  Widget _divider() {
//    return Padding(
//      padding: const EdgeInsets.symmetric(horizontal: 16),
//      child: Divider(
//        height: 1.0,
//        color: HexColor('#D7D7D7'),
//      ),
//    );
//  }
//
//  Widget _buildInfoContainer({String label, Locale locale}) {
//    return InkWell(
//      onTap: () {
//        setState(() {
//          selectedLocale = locale;
//        });
//      },
//      child: Container(
//        height: 56,
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.start,
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
//              child: Text(
//                label,
//                style: TextStyle(color: HexColor("#333333"), fontSize: 16),
//              ),
//            ),
//            Spacer(),
//            Visibility(
//              visible: selectedLocale.languageCode == locale.languageCode,
//              child: Padding(
//                padding: const EdgeInsets.fromLTRB(16, 15, 15, 13),
//                child: Icon(
//                  Icons.check,
//                  color: Colors.green,
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  void switchLanguage(Locale locale) {
//    localeChange(locale);
//  }
//}
