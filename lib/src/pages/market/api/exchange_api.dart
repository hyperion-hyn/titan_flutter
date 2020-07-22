import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_const.dart';
import 'package:titan/src/pages/market/entity/market_info_entity.dart';
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
        _instance.dio.interceptors
            .add(LogInterceptor(responseBody: true, requestBody: true));
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
  }) async {
    var path = '/api/user/walletSignLogin';

    //get a seed
    var seed = await _getAccessSeed(address, path);
    var params = {
      'address': address,
      'seed': seed,
    };
    //sign request with seed
    var signed = await Signer.signApi(
      wallet,
      password,
      'POST',
      Const.EXCHANGE_DOMAIN.split('//')[1],
      path,
      params,
    );
    params['sign'] = signed;

    return await ExchangeHttp.instance.postEntity(
      path,
      null,
      params: params,
    );
  }

  Future<dynamic> getAssetsList() async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ACCOUNT_ASSETS,
      null,
      params: {},
    );
  }

  Future<dynamic> type2currency(String type, String currency) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_TYPE_TO_CURRENCY,
      null,
      params: {
        type: type,
        currency: currency,
      },
    );
  }

  Future<dynamic> testRecharge(String type, double balance) async {
    return await ExchangeHttp.instance
        .postEntity(ExchangeConst.PATH_QUICK_RECHARGE, null, params: {
      "type": type,
      "balance": balance,
    });
  }

  Future<ResponseEntity> transferAccountToExchange(
    String type,
    String balance,
  ) async {
    return await ExchangeHttp.instance.postResponseEntity(
      ExchangeConst.PATH_TO_EXCHANGE,
      null,
      params: {
        "type": type,
        "balance": balance,
      },
    );
  }

  Future<ResponseEntity> transferExchangeToAccount(
    String type,
    String balance,
  ) async {
    return await ExchangeHttp.instance.postResponseEntity(
      ExchangeConst.PATH_TO_ACCOUNT,
      null,
      params: {
        "type": type,
        "balance": balance,
      },
    );
  }

  Future<MarketInfoEntity> getMarketInfo(String market) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_MARKET_INFO,
      EntityFactory<MarketInfoEntity>((marketInfo) => MarketInfoEntity.fromJson(marketInfo)),
      params: {
        "market": market,
      },
    );
  }

  Future<dynamic> orderPutLimit(String market, exchangeType,String price,String amount) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ORDER_LIMIT,
      null,
      params: {
        "market": market,
        "side": exchangeType,
        "price": price,
        "amount": amount,
        "option": "GTC",
      },
    );
  }

  Future<dynamic> orderPutMarket(String market, exchangeType,String amount) async {
    return await ExchangeHttp.instance.postEntity(
      ExchangeConst.PATH_ORDER_MARKET,
      null,
      params: {
        "market": market,
        "side": exchangeType,
        "amount": amount,
      },
    );
  }
}
