import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/config/consts.dart';


class AtlasHttpCore extends BaseHttpCore {
  factory AtlasHttpCore() => _getInstance();

  AtlasHttpCore._internal() : super(_dio);

  static AtlasHttpCore get instance => _getInstance();
  static AtlasHttpCore _instance;

  static AtlasHttpCore _getInstance() {
    if (_instance == null) {
      _instance = AtlasHttpCore._internal();

      // todo: test_jison_0822_close_log
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.ATLAS_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
