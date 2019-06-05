import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/bloc/bloc_provider.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/app_bloc.dart';
import 'bloc/search_history_bloc.dart';
import 'business/home/home.dart';
import 'di/dependency_injection.dart';
import 'resource/api/api.dart';
import 'resource/repository/repository.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  var _repository = Repository(api: Api());
  var _appBloc = AppBloc();
  var _searchHistoryBloc = SearchHistoryBloc();

  @override
  Widget build(BuildContext context) {
    return Injector(
      repository: _repository,
      child: BlocProvider(
        bloc: _appBloc,
        child: BlocProvider(
          bloc: _searchHistoryBloc,
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appBloc.dispose();
    super.dispose();
  }
}
