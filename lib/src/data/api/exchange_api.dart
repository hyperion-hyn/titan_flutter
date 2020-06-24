import 'package:dio/dio.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/config/consts.dart';

class ExchangeHttp extends BaseHttpCore {
  factory ExchangeHttp() => _getInstance();

  ExchangeHttp._internal()
      : super(
          Dio(
            BaseOptions(
              baseUrl: Const.EXCHANGE_DOMAIN,
//              contentType: 'application/x-www-form-urlencoded',
            ),
          ),
        );

  static ExchangeHttp _instance;

  static ExchangeHttp get instance => _getInstance();

  static ExchangeHttp _getInstance() {
    if (_instance == null) {
      _instance = ExchangeHttp._internal();
      if (env.buildType == BuildType.DEV) {
        _instance.dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
      }
    }
    return _instance;
  }
}

class ExchangeApi {
  Future<String> ping(String p) async {
    return await ExchangeHttp.instance.postEntity(
      'api/index/ping',
      EntityFactory((json) => json),
      params: {'p': p},
    );
  }
}
