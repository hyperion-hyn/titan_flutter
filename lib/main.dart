import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/domain/firebase.dart';

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

  FlutterError.onError = (FlutterErrorDetails details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };

  TitanPlugin.initFlutterMethodCall();
  TitanPlugin.initKeyPair();

  Api api = Api();
  SearchHistoryDao searchDao = SearchHistoryDao();
  Repository repository = Repository(api: api, searchHistoryDao: searchDao);
  SearchInteractor searchInteractor = SearchInteractor(repository);

  BlocSupervisor.delegate = AppBlocDelegate();

  runZoned<Future<void>>(() async {
    runApp(Injector(
      child: FireBaseLogic(
        child: App(),
      ),
      repository: repository,
      searchInteractor: searchInteractor,
    ));
  }, onError: (error, stackTrace) {
    print(error);
    print(stackTrace);
    if (error is HttpResponseCodeNotSuccess) {
      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      Fluttertoast.showToast(msg: notSuccessError.message);
    } else if (error is DioError) {
      Fluttertoast.showToast(msg: "网络错误");
    } else {
      Fluttertoast.showToast(msg: "服务器正忙，请稍后再试");
    }
  });

//  FlutterBugly.postCatchedException(() {
//    //init dependency
//
//  });
}
