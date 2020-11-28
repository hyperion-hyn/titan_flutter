import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/config/consts.dart';

class RPHttpCore extends BaseHttpCore {
  factory RPHttpCore() => _getInstance();

  RPHttpCore._internal() : super(_dio);

  static RPHttpCore get instance => _getInstance();
  static RPHttpCore _instance;

  static RPHttpCore _getInstance() {
    if (_instance == null) {
      _instance = RPHttpCore._internal();

      if (showLog) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.RP_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));


  static void clearInstance() {
    _instance = null;

    _dio = null;
    _dio = new Dio(BaseOptions(
      baseUrl: Const.RP_DOMAIN,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      contentType: 'application/x-www-form-urlencoded',
    ));
  }
}

// no log
class RPHttpCoreNoLog extends BaseHttpCore {
  factory RPHttpCoreNoLog() => _getInstance();

  RPHttpCoreNoLog._internal() : super(_dio);

  static RPHttpCoreNoLog get instance => _getInstance();
  static RPHttpCoreNoLog _instance;

  static RPHttpCoreNoLog _getInstance() {
    if (_instance == null) {
      _instance = RPHttpCoreNoLog._internal();
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.RP_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
