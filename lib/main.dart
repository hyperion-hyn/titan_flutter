import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/config.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/business/home/home_page.dart';
import 'package:titan/src/business/position/confirm_position_page.dart';
import 'package:titan/src/global.dart';

import 'env.dart';
import 'src/basic/bloc/app_bloc_delegate.dart';
import 'src/data/api/api.dart';
import 'src/data/db/search_history_dao.dart';
import 'src/data/repository/repository.dart';
import 'src/domain/domain.dart';
import 'src/inject/injector.dart';
import 'src/plugins/titan_plugin.dart';

void main() {
  if (env == null) {
    BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);
  }

  WidgetsFlutterBinding.ensureInitialized();
  TitanPlugin.initFlutterMethodCall();
  //init key for security share
  TitanPlugin.initKeyPair();

  Api api = Api();
  SearchHistoryDao searchDao = SearchHistoryDao();
  Repository repository = Repository(api: api, searchHistoryDao: searchDao);
  SearchInteractor searchInteractor = SearchInteractor(repository);

  BlocSupervisor.delegate = AppBlocDelegate();

  if (env.buildType == BuildType.PROD) {
    FlutterBugly.init(androidAppId: Config.BUGLY_ANDROID_APPID, iOSAppId: Config.BUGLY_IOS_APPID);
  }

  FlutterBugly.postCatchedException(
    () {
      runApp(Injector(
        child: App(),
//        child: MaterialApp(
//          home: HomePage(),
//          routes: <String, WidgetBuilder>{
//          ROUTE_CONFIRM_POSITION_PAGE : (BuildContext context) => new ConfirmPositionPage()
//        },),
        repository: repository,
        searchInteractor: searchInteractor,
      ));
    },
    debugUpload: env.buildType == BuildType.DEV,
  );
}
