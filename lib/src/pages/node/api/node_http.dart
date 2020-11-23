import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/config/consts.dart';


class NodeHttpCore extends BaseHttpCore {
  factory NodeHttpCore() => _getInstance();

  NodeHttpCore._internal() : super(_dio);

  static NodeHttpCore get instance => _getInstance();
  static NodeHttpCore _instance;

  static NodeHttpCore _getInstance() {
    if (_instance == null) {
      _instance = NodeHttpCore._internal();

      if (showLog) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true));
      }
    }
    return _instance;
  }

  static var _dio = new Dio(BaseOptions(
    baseUrl: Const.NODE_DOMAIN,
    connectTimeout: 5000,
    receiveTimeout: 5000,
//    headers: {"user-agent": "dio", "api": "1.0.0"},
    /*contentType: ContentType.JSON,
      responseType: ResponseType.PLAIN*/
    contentType: 'application/x-www-form-urlencoded',
  ));
}
