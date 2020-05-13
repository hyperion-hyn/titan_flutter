import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/config/consts.dart';

class NewsHttpCore extends BaseHttpCore {
  factory NewsHttpCore() => _getInstance();

  NewsHttpCore._internal() : super(_dio);

  static NewsHttpCore get instance => _getInstance();
  static NewsHttpCore _instance;

  static NewsHttpCore _getInstance() {
    if (_instance == null) {
      _instance = NewsHttpCore._internal();
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true, requestHeader: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.NEWS_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 10000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    contentType: "application/json",
//      responseType: ResponseType.PLAIN
//    contentType: ContentType.parse('application/x-www-form-urlencoded'),
  ));
}
