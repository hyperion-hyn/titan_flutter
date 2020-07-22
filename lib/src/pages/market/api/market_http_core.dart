
import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/config/consts.dart';

class MarketHttpCore extends BaseHttpCore {
  factory MarketHttpCore() => _getInstance();

  MarketHttpCore._internal() : super(_dio);

  static MarketHttpCore get instance => _getInstance();
  static MarketHttpCore _instance;

  static MarketHttpCore _getInstance() {
    if (_instance == null) {
      _instance = MarketHttpCore._internal();

      // todo: test_jison_0428_close_log
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.MARKET_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
