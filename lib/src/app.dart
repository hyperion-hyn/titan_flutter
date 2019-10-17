import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/theme.dart';

import 'business/updater/bloc/bloc.dart';
import 'global.dart';
import 'home_build.dart';

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

//    FlutterBugly.init(androidAppId: "103fd7ef12", iOSAppId: "0198fbe26a");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => AppBloc(),
      child: RefreshConfiguration(
        dragSpeedRatio: 0.91,
        headerTriggerDistance: 80,
        footerTriggerDistance: 80,
        maxOverScrollExtent :100,
        maxUnderScrollExtent:0,
        headerBuilder: () => WaterDropMaterialHeader(),
        footerBuilder: () => ClassicFooter(),
        autoLoad: true,
        enableLoadingWhenFailed: false,
        hideFooterWhenNotFull: true,
        enableBallisticLoad: true,
        child: MaterialApp(
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
          home: HomeBuilder(),
          navigatorObservers: [routeObserver],
        ),
      ),
    );
  }
}
