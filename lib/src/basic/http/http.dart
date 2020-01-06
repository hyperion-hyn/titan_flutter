import 'package:dio/dio.dart';
import 'package:titan/src/config/consts.dart';

import '../../../env.dart';
import 'base_http.dart';

class HttpCore extends BaseHttpCore {
  factory HttpCore() => _getInstance();

  HttpCore._internal() : super(_dio);

  static HttpCore get instance => _getInstance();
  static HttpCore _instance;

  static HttpCore _getInstance() {
    if (_instance == null) {
      _instance = HttpCore._internal();
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
