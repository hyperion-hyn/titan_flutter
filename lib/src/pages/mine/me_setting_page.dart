import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/mine/me_theme_page.dart';

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
    var quoteStr = WalletInheritedModel.of(context, aspect: WalletAspect.quote).activeLegal.legal;
    var area = SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.name(context);
    var theme = SettingInheritedModel.of(context, aspect: SettingAspect.theme)?.themeModel?.theme;

    Widget _lineWidget({double height = 5}) {
      return Container(
        height: height,
        color: HexColor('#F8F8F8'),
      );
    }

    Widget _dividerWidget() {
      return Padding(
        padding: const EdgeInsets.only(
          left: 16,
        ),
        child: Container(
          height: 0.8,
          color: HexColor('#F8F8F8'),
        ),
      );
    }

    return Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).setting,
          backgroundColor: Colors.white,
          showBottom: true,
        ),
        body: Column(
          children: <Widget>[
            _buildMenuBar(S.of(context).price_show, quoteStr, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MePricePage()));
            }),
            _dividerWidget(),
            _buildMenuBar(S.of(context).language, language, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MeLanguagePage()));
            }),
            _lineWidget(height: 10),
            _buildMenuBar(S.of(context).app_area_setting, area, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MeAreaPage()));
            }),
            _lineWidget(height: 10),
            _buildMenuBar(
              '主题',
              '',
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MeThemePage()));
              },
              color: theme?.primaryColor ?? Theme.of(context).primaryColor,
            ),
          ],
        ));
  }

  Widget _buildMenuBar(String title, String subTitle, Function onTap, {Color color, BuildContext context}) {
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
                  title?.isNotEmpty ?? false ? title : "",
                  style: TextStyle(color: HexColor("#333333"), fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
              Spacer(),
              (subTitle?.isNotEmpty ?? false)
                  ? Text(
                      subTitle,
                      style: TextStyle(color: HexColor("#AAAAAA"), fontSize: 12),
                    )
                  : Container(
                      height: 25,
                      width: 60,
                      color: color ?? Theme.of(context).primaryColor,
                    ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 14, 20),
                child: Image.asset(
                  'res/drawable/me_account_bind_arrow.png',
                  width: 7,
                  height: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
