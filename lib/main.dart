import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/src/app.dart';

import 'env.dart';
import 'src/bloc/app_bloc_delegate.dart';
import 'src/data/api/api.dart';
import 'src/data/db/search_history_dao.dart';
import 'src/data/repository/repository.dart';
import 'src/domain/domain.dart';
import 'src/inject/injector.dart';
import 'src/plugins/titan_plugin.dart';

void main() {
  if (env == null) {
    BuildEnvironment.init(flavor: BuildFlavor.official, buildType: BuildType.dev);
  }

  TitanPlugin.initFlutterMethodCall();
  TitanPlugin.initKeyPair();

  FlutterBugly.postCatchedException(() {
    //init dependency
    Api api = Api();
    SearchHistoryDao searchDao = SearchHistoryDao();
    Repository repository = Repository(api: api, searchHistoryDao: searchDao);
    SearchInteractor searchInteractor = SearchInteractor(repository);

    BlocSupervisor.delegate = AppBlocDelegate();
    runApp(Injector(child: App(), api: api, searchDao: searchDao, repository: repository, searchInteractor: searchInteractor));
  });
}
