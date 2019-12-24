import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/components/style/theme.dart';

import 'business/updater/bloc/bloc.dart';
import 'components/root_page_control_component/root_page_control_component.dart';
import 'global.dart';

ValueChanged<Locale> localeChange;
ValueChanged<AppArea> appAreaChange;

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
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
    getLocale();
  }

  Future getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var languageCode = prefs.getString(PrefsKey.appLanguageCode);
    var countryCode = prefs.getString(PrefsKey.appCountryCode);
    if (languageCode == null) {
      return;
    }
    localeChange(Locale(languageCode, countryCode));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => AppBloc(),
      child: RefreshConfiguration(
        //pull to refresh config
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
          locale: appLocale == null ? null : appLocale,
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
//          home: HomeBuilder(),
          home: RootPageControlComponent(),
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
