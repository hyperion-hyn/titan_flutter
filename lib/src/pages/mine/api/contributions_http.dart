import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/config/consts.dart';

class ContributionsHttpCore extends BaseHttpCore {
  factory ContributionsHttpCore() => _getInstance();

  ContributionsHttpCore._internal() : super(_dio);

  static ContributionsHttpCore get instance => _getInstance();
  static ContributionsHttpCore _instance;

  static ContributionsHttpCore _getInstance() {
    if (_instance == null) {
      _instance = ContributionsHttpCore._internal();

      if (showLog) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.CONTRIBUTIONS_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}

// no log
class ContributionsHttpCoreNoLog extends BaseHttpCore {
  factory ContributionsHttpCoreNoLog() => _getInstance();

  ContributionsHttpCoreNoLog._internal() : super(_dio);

  static ContributionsHttpCoreNoLog get instance => _getInstance();
  static ContributionsHttpCoreNoLog _instance;

  static ContributionsHttpCoreNoLog _getInstance() {
    if (_instance == null) {
      _instance = ContributionsHttpCoreNoLog._internal();
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.CONTRIBUTIONS_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
