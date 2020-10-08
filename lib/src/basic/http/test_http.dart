import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/src/config/consts.dart';

import 'base_http.dart';

class TestHttpCore extends BaseHttpCore {
  factory TestHttpCore() => _getInstance();

  TestHttpCore._internal() : super(_dio);

  static TestHttpCore get instance => _getInstance();
  static TestHttpCore _instance;

  static TestHttpCore _getInstance() {
    if (_instance == null) {
      _instance = TestHttpCore._internal();
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.LOCAL_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
