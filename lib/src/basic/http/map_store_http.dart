import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/consts/consts.dart';

import '../../../env.dart';
import 'entity.dart';
import 'http_exception.dart';

class MapStoreHttpCore extends BaseHttpCore {
  factory MapStoreHttpCore() => _getInstance();

  MapStoreHttpCore._internal() : super(_dio);

  static MapStoreHttpCore get instance => _getInstance();
  static MapStoreHttpCore _instance;

  static MapStoreHttpCore _getInstance() {
    if (_instance == null) {
      _instance = MapStoreHttpCore._internal();
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true, requestHeader: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.MAP_STORE_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 10000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    contentType: 'application/json',
//      responseType: ResponseType.PLAIN
//    contentType: ContentType.parse('application/x-www-form-urlencoded'),
  ));
}
