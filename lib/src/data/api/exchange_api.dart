import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ExchangeHttp extends BaseHttpCore {
  factory ExchangeHttp() => _getInstance();

  ExchangeHttp._internal()
      : super(
          Dio(
            BaseOptions(
              baseUrl: Const.EXCHANGE_DOMAIN,
              contentType: 'application/x-www-form-urlencoded',
            ),
          )..interceptors.add(CookieManager(CookieJar())), //cookie 存在内存而已
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
  Future<String> ping(String name) async {
    return await ExchangeHttp.instance.postEntity(
      'api/index/ping',
      EntityFactory((json) => json),
      params: {'name': name},
    );
  }

  ///使用[address]钱包地址 和 访问路径[path]获取一个种子
  Future<String> _getAccessSeed(String address, String path) async {
    return await ExchangeHttp.instance.postEntity(
      '/api/user/getAccessSeed',
      null,
      params: {
        'address': address,
        'path': path,
      },
    );
  }

  Future<dynamic> sendSms({String email, String language = 'zh-CN'}) async {
    return await ExchangeHttp.instance.postEntity(
      '/api/user/mregister',
      null,
      params: {
        'email': email,
        'type': 1,
        'language': language,
      },
    );
  }

  ///使用钱包注册/登录
  Future<dynamic> walletSignLogin({
    Wallet wallet,
    String password,
    String address,
    String email,
    String token,
    String code,
  }) async {
    var path = '/api/user/walletSignLogin';

    //get a seed
    var seed = await _getAccessSeed(address, path);
    var params = {
      'address': address,
      'seed': seed,
      'email': email,
      'token': token,
      'code': code,
    };
    //sign request with seed
    var signed = await Signer.signApi(wallet, password, 'POST', Const.EXCHANGE_DOMAIN.split('//')[1], path, params);
    params['sign'] = signed;

    return await ExchangeHttp.instance.postEntity(
      path,
      null,
      params: params,
    );
  }
}