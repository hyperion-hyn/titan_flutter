import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'basic/bloc/persist_bloc_holder.dart';
import 'bloc/bloc.dart';
import 'business/home/bloc/bloc.dart';
import 'business/home/home_page.dart';

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
    return PersistBlocHolder(
      createBloc: () => AppBloc(),
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
            return PersistBlocHolder<HomeBloc>(
              child: HomePage(),
              createBloc: () => HomeBloc(),
            );
          },
        ),
      ),
    );
  }
}
