import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/app_bloc.dart';
import 'bloc/search_history_bloc.dart';
import 'resource/api/api.dart';
import 'resource/db/search_history_dao.dart';
import 'resource/repository/repository.dart';

import 'business/home/home_page.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [Bloc((inject) => AppBloc()), Bloc((inject) => SearchHistoryBloc(inject.get<SearchHistoryDao>()))],
      dependencies: [
        Dependency((inject) => Api()),
        Dependency((inject) => SearchHistoryDao()),
        Dependency((inject) => Repository(api: inject.get<Api>(), searchHistoryDao: inject.get<SearchHistoryDao>()))
      ],
      child: MaterialApp(
        key: Keys.materialAppKey,
        title: 'Titan',
        theme: appTheme,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(key: Keys.mainContextKey, builder: (context) => HomePage()),
      ),
    );
  }
}
