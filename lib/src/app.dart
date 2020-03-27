import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/theme.dart';

import 'business/updater/bloc/bloc.dart';
import 'global.dart';
import 'guide.dart';

ValueChanged<Locale> localeChange;
ValueChanged<AppArea> appAreaChange;

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends BaseState<App> {
  @override
  void initState() {
    super.initState();
    localeChange = (locale) {
      saveLocale(locale);
      setState(() {
        appLocale = locale;
      });
    };
    appAreaChange = (appArea) {
      saveAppArea(appArea);
      setState(() {
        currentAppArea = appArea;
      });
    };
  }

  @override
  void onCreated() {
    _getLocale();
  }

  Future _getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var languageCode = prefs.getString(PrefsKey.appLanguageCode);
    var countryCode = prefs.getString(PrefsKey.appCountryCode);
    if (languageCode == null) {
      //set default locale
      var l = window.locale?.languageCode;
      if (l == 'zh' || l?.contains('zh_Hans') == true) {
        localeChange(Locale("zh", "CN"));
      }
      else if (l == 'zh_HK') {
        localeChange(Locale('zh', 'HK'));
      }
      else if (l == 'ko') {
        localeChange(Locale('ko', ''));
      }
      else {
        localeChange(Locale('en', ''));
      }
      return;
    }
    localeChange(Locale(languageCode, countryCode));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => AppBloc(),
      child: RefreshConfiguration(
        dragSpeedRatio: 0.91,
        headerTriggerDistance: 80,
        footerTriggerDistance: 80,
        maxOverScrollExtent: 100,
        maxUnderScrollExtent: 0,
        headerBuilder: () => WaterDropMaterialHeader(),
        footerBuilder: () => ClassicFooter(),
        autoLoad: true,
        enableLoadingWhenFailed: false,
        hideFooterWhenNotFull: true,
        enableBallisticLoad: true,
        child: MaterialApp(
          locale: appLocale == null ? defaultLocale : appLocale,
          debugShowCheckedModeBanner: false,
          key: Keys.materialAppKey,
          title: 'Titan',
          theme: appTheme,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            RefreshLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: GuidePage(),
          navigatorObservers: [routeObserver],
        ),
      ),
    );
  }

  Future saveAppArea(AppArea appArea) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsKey.appArea, appArea.key);
  }

  Future saveLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsKey.appLanguageCode, locale.languageCode);
    prefs.setString(PrefsKey.appCountryCode, locale.countryCode);
  }


}
