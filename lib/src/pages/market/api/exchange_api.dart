import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/http/base_http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_const.dart';
import 'package:titan/src/pages/market/entity/exchange_banner.dart';
import 'package:titan/src/pages/market/entity/market_info_entity.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/order/entity/order_detail.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as rsa;
import 'package:pointycastle/asymmetric/api.dart';

import '../../../../config.dart';

class ExchangeHttp extends BaseHttpCore {
  factory ExchangeHttp() => _getInstance();

  ExchangeHttp._internal()
      : super(
          Dio(
            BaseOptions(
              baseUrl: ExchangeConst.EXCHANGE_DOMAIN,
              contentType: 'application/x-www-form-urlencoded',
            ),
          ), //cookie 存在内存而已
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
  ExchangeHttp exchangeHttp;

  ExchangeApi() {
    init();
  }

  init() {
    exchangeHttp = ExchangeHttp.instance;

    getCookieDir().then((value) => {
          exchangeHttp.dio.interceptors
              .add(CookieManager(PersistCookieJar(dir: value)))
        });
  }

  Future<String> getCookieDir() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    return '$appDocPath/.cookies/';
  }

  Future<String> ping(String name) async {
    return await exchangeHttp.postEntity(
      'api/index/ping',
      EntityFactory((json) => json),
      params: {'name': name},
    );
  }

  ///使用[address]钱包地址 和 访问路径[path]获取一个种子
  Future<String> _getAccessSeed(String address, String path) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_GET_ACCESS_SEED,
      null,
      params: {
        'address': address,
        'path': path,
      },
    );
  }

  Future<dynamic> sendSms({String email, String language = 'zh-CN'}) async {
    return await exchangeHttp.postEntity(
      '/api/user/mregister',
      null,
      params: {
        'email': email,
        'type': 1,
        'language': language,
      },
    );
  }

  Future<List<ExchangeBanner>> getBannerList() async {
    return await exchangeHttp.postEntity(ExchangeConst.PATH_BANNER_LIST,
        EntityFactory<List<ExchangeBanner>>((data) {
      var bannerList = List<ExchangeBanner>();

      (data as List).forEach((item) {
        bannerList.add(ExchangeBanner.fromJson(item));
      });
      return bannerList;
    }), params: {});
  }

  ///使用钱包注册/登录
  Future<dynamic> walletLogin({
    Wallet wallet,
    String password,
    String address,
  }) async {
    return await walletSignAndPost(
      path: ExchangeConst.PATH_LOGIN_REGISTER,
      wallet: wallet,
      password: password,
      address: address,
    );
  }

  ///Post with Sign
  Future<dynamic> walletSignAndPost({
    String path,
    Wallet wallet,
    String password,
    String address,
    Map<String, dynamic> params,
  }) async {
    var _params = params ?? {};
    _params['address'] = address;
    _params['seed'] = Random().nextInt(0xfffffffe).toString();
    _params['ts'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    var signed = await Signer.signApiWithWallet(
      wallet,
      password,
      'POST',
      ExchangeConst.EXCHANGE_DOMAIN.split('//')[1],
      path,
      _params,
    );
    _params['sign'] = signed;

    return await exchangeHttp.postEntity(
      path,
      null,
      params: _params,
    );
  }

  Future<dynamic> getAssetsList() async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_ACCOUNT_ASSETS,
      null,
      params: {},
    );
  }

  Future<dynamic> type2currency(String _type, String _currency) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_TYPE_TO_CURRENCY,
      null,
      params: {
        'type': _type,
        'currency': _currency,
      },
    );
  }

  Future<dynamic> testRecharge(String type, double balance) async {
    return await exchangeHttp
        .postEntity(ExchangeConst.PATH_QUICK_RECHARGE, null, params: {
      "type": type,
      "balance": balance,
    });
  }

  Future<dynamic> withdraw(
    Wallet wallet,
    String password,
    String address,
    String type,
    String outerAddress,
    String balance,
      String gasFee,
  ) async {
    return await walletSignAndPost(
        path: ExchangeConst.PATH_WITHDRAW,
        wallet: wallet,
        password: password,
        address: address,
        params: {
          'type': type,
          'outer_address': outerAddress,
          'balance': balance,
          'fee': gasFee,
        });
  }

  Future<dynamic> getAddress(String type) async {
    return postAndVerifySign(ExchangeConst.PATH_GET_ADDRESS, params: {
      'type': type,
    });
  }

  Future<MarketInfoEntity> getMarketInfo(String market) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_MARKET_INFO,
      EntityFactory<MarketInfoEntity>(
          (marketInfo) => MarketInfoEntity.fromJson(marketInfo)),
      params: {
        "market": market,
      },
    );
  }

  Future<dynamic> getMarketAllSymbol() async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_MARKET_ALL,
      null,
      params: {},
    );
  }

  Future<dynamic> orderPutLimit(
      String market, exchangeType, String price, String amount) async {
    return await exchangeHttp.postEntity(
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

  Future<dynamic> orderPutMarket(
      String market, exchangeType, String amount) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_ORDER_MARKET,
      null,
      params: {
        "market": market,
        "side": exchangeType,
        "amount": amount,
      },
    );
  }

  Future<dynamic> orderCancel(String orderId) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_ORDER_CANCEL,
      null,
      params: {"order_id": orderId},
    );
  }

  Future<dynamic> historyTrade(String symbol, {String limit = '100'}) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_HISTORY_TRADE,
      null,
      params: {
        "symbol": symbol,
        "limit": limit,
      },
    );
  }

  Future<dynamic> historyDepth(String symbol, {int precision = -1}) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_HISTORY_DEPTH,
      null,
      params: {
        "symbol": symbol,
        "precision": precision,
      },
    );
  }

  Future<List<Order>> getOrderList(
    String market,
    int page,
    int size,
    String method,
  ) async {
    return await exchangeHttp.postEntity(ExchangeConst.PATH_ORDER_LIST,
        EntityFactory<List<Order>>((response) {
      var orderList = List<Order>();
      if (response is Map && response.length == 0) {
        return orderList;
      }
      var dataList = response['data'];
      (dataList as List).forEach((item) {
        orderList.add(Order.fromJson(item));
      });
      return orderList;
    }), params: {
      'market': market,
      'page': page,
      'size': size,
      'method': method,
    });
  }

  Future<List<AssetHistory>> getAccountHistory(
    String type,
    int page,
    int size,
    String action,
  ) async {
    return await exchangeHttp.postEntity(ExchangeConst.PATH_ASSETS_HISTORY,
        EntityFactory<List<AssetHistory>>((response) {
      var assetHistoryList = List<AssetHistory>();
      if (response is Map && response.length == 0) {
        return assetHistoryList;
      }
      var dataList = response['data'];
      (dataList as List).forEach((item) {
        assetHistoryList.add(AssetHistory.fromJson(item));
      });
      return assetHistoryList;
    }), params: {
      'type': type,
      'page': page,
      'size': size,
      'action': action,
    });
  }

  Future<List<OrderDetail>> getOrderDetailList(
    String market,
    int page,
    int size,
  ) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_ORDER_LOG_LIST,
      EntityFactory<List<OrderDetail>>((response) {
        var orderDetailList = List<OrderDetail>();
        if (response is Map && response.length == 0) {
          return orderDetailList;
        }
        var dataList = response['data'];
        (dataList as List).forEach((item) {
          orderDetailList.add(OrderDetail.fromJson(item));
        });
        return orderDetailList;
      }),
      params: {
        'market': market,
        'page': page,
        'size': size,
      },
    );
  }

  Future<dynamic> historyKline(
    String symbol, {
    String period = '15min',
  }) async {
    return await exchangeHttp.postEntity(
      ExchangeConst.PATH_HISTORY_KLINE,
      null,
      params: {
        "name": symbol,
        "period": period,
      },
    );
  }

  Future<dynamic> postAndVerifySign(
    String url, {
    Map<String, dynamic> params,
  }) async {
    var data = await exchangeHttp.postEntity(
      url,
      null,
      params: params,
    );

    if (verifySign(data)) {
      return data;
    } else {
      throw HttpResponseCodeNotSuccess(500, 'sign verify error!');

      //throw FormatException('sign verify error: ' + data);
    }
  }

  bool verifySign(Map data) {
//    Map params = json.decode(data);
    var paramsStr = '';
    var sortedParams = data.keys.toList()..sort();
    for (var k in sortedParams) {
      if (k != 'sign') {
        if (paramsStr != '') {
          paramsStr += '&';
        }
        paramsStr += '$k=${Uri.encodeComponent(data[k].toString())}';
      }
    }

    var parser = rsa.RSAKeyParser();
    var k = utf8.decode(base64Decode(env.buildType == BuildType.DEV
        ? Config.EXCHANGE_API_SIGN_PUBLIC_KEY_TEST
        : Config.EXCHANGE_API_SIGN_PUBLIC_KEY));
    var publicKey = parser.parse(k) as RSAPublicKey;

    var signer = rsa.Signer(
      rsa.RSASigner(rsa.RSASignDigest.SHA256, publicKey: publicKey),
    );

    return signer.verify64(paramsStr, data['sign']);
  }
}
