import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/bloc.dart';
import 'business/home/bloc/bloc.dart';
import 'business/home/home_page.dart';
import 'business/home/map/bloc/bloc.dart';
import 'business/home/searchbar/bloc/bloc.dart';
import 'business/home/sheets/bloc/bloc.dart';

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

    FlutterBugly.init(androidAppId: "103fd7ef12", iOSAppId: "0198fbe26a");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => AppBloc(context: context),
      child: MaterialApp(
        key: Keys.materialAppKey,
        title: 'Titan',
        theme: appTheme,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          key: Keys.mainContextKey,
          builder: (context) {
            return MultiBlocProvider(
              child: HomePage(),
              providers: [
                BlocProvider<SheetsBloc>(builder: (context) => SheetsBloc(context: context)),
                BlocProvider<MapBloc>(builder: (context) => MapBloc(context: context)),
                BlocProvider<SearchbarBloc>(builder: (context) => SearchbarBloc(context: context)),
                BlocProvider<HomeBloc>(builder: (context) => HomeBloc(context: context)),
              ],
            );
          },
        ),
      ),
    );
  }
}
