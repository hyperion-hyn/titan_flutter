import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'business/home/home_widget.dart';
import 'di/dependency_injection.dart';
import 'resource/api/api.dart';
import 'resource/repository/repository.dart';

//init dependency inject
var _repository = Repository(api: Api());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      repository: _repository,
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
