import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';

class MapRichHttpCore extends BaseHttpCore {
  factory MapRichHttpCore() => _getInstance();

  MapRichHttpCore._internal() : super(_dio);

  static MapRichHttpCore get instance {
    _dio.options.baseUrl = Config.MAP_RICH_DOMAIN;
    return _getInstance();
  }

  static MapRichHttpCore _instance;

  static MapRichHttpCore _getInstance() {
    if (_instance == null) {
      _instance = MapRichHttpCore._internal();
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(
          responseBody: true,
          requestBody: true,
          requestHeader: true,
        ));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 10000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    contentType: "application/json",
//      responseType: ResponseType.PLAIN
//    contentType: ContentType.parse('application/x-www-form-urlencoded'),
  ));
}
