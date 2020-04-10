import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';

import 'me_area_page.dart';
import 'me_language_page.dart';
import 'me_price_page.dart';

class MeSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeSettingState();
  }
}

class _MeSettingState extends State<MeSettingPage> {
  @override
  Widget build(BuildContext context) {
    var language = SettingInheritedModel.of(context, aspect: SettingAspect.language).languageModel.name;
    var quoteStr = QuotesInheritedModel.of(context,aspect: QuotesAspect.quote).activeQuotesSign?.quote;
    var area = SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.name(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            S.of(context).setting,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            _buildMemuBar("价格显示", quoteStr, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MePricePage()));
            }),
            Divider(
              height: 8,
            ),
            _buildMemuBar(S.of(context).language, language, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MeLanguagePage()));
            }),
            Divider(
              height: 1,
            ),
            _buildMemuBar(S.of(context).app_area_setting, area, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MeAreaPage()));
            }),
            Divider(
              height: 1,
            )
          ],
        ));
  }
}

Widget _buildMemuBar(String title, String subTitle, Function onTap) {
  return Material(
    child: InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                title,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
            Spacer(),
            Text(
              subTitle,
              style: TextStyle(color: HexColor("#AAAAAA"), fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 15, 14, 15),
              child: Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
