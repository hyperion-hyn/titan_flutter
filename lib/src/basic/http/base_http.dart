import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';

import '../../../config.dart';
import '../../../env.dart';
import 'entity.dart';
import 'http_exception.dart';

class BaseHttpCore {
  final Dio dio;
  var packageInfo;

  BaseHttpCore(this.dio) {
    //hack method
    dio.options.connectTimeout = 10000;
  }

  static const String GET = "get";
  static const String POST = "post";
  static const String PATCH = "patch";

  Future<ResponseEntity<T>> getResponseEntity<T>(String url, EntityFactory<T> factory,
      {Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    var res = await get(url, params: params, options: options, cancelToken: cancelToken);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  Future<ResponseEntity<T>> postResponseEntity<T>(String url, EntityFactory<T> factory,
      {dynamic data, Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    var res = await post(url, data: data, params: params, options: options, cancelToken: cancelToken);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  Future<ResponseEntity<T>> patchResponseEntity<T>(String url, EntityFactory<T> factory,
      {Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    var res = await patch(url, params: params, options: options, cancelToken: cancelToken);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  Future<T> getEntity<T>(String url, EntityFactory<T> factory,
      {Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    var responseEntity =
        await getResponseEntity<T>(url, factory, params: params, options: options, cancelToken: cancelToken);
    if (responseEntity.code != ResponseCode.SUCCESS && responseEntity.code != 200) {
      throw HttpResponseCodeNotSuccess(responseEntity.code, responseEntity.msg);
    }
    //print('[request] responseEntity.data:${responseEntity.data}');
    return responseEntity.data;
  }

  Future<T> postEntity<T>(String url, EntityFactory<T> factory,
      {dynamic data, Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    var responseEntity = await postResponseEntity<T>(url, factory,
        data: data, params: params, options: options, cancelToken: cancelToken);
    if (responseEntity.code != ResponseCode.SUCCESS && responseEntity.code != 200) {
      throw HttpResponseCodeNotSuccess(responseEntity.code, responseEntity.msg);
    }
    return responseEntity.data;
  }

  Future<T> patchEntity<T>(String url, EntityFactory<T> factory,
      {Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    var responseEntity =
        await patchResponseEntity<T>(url, factory, params: params, options: options, cancelToken: cancelToken);
    if (responseEntity.code != ResponseCode.SUCCESS && responseEntity.code != 200) {
      throw HttpResponseCodeNotSuccess(responseEntity.code, responseEntity.msg);
    }
    return responseEntity.data;
  }

  //get method
  Future<dynamic> get(String url, {Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    return _request(url, method: GET, params: params, options: options, cancelToken: cancelToken);
  }

  //post method
  Future<dynamic> post(String url,
      {dynamic data,
      Map<String, dynamic> params,
      Options options,
      CancelToken cancelToken,
      ProgressCallback onSendProgress}) async {
    return _request(url,
        method: POST,
        data: data,
        params: params,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress);
  }

  //patch method
  Future<dynamic> patch(String url, {Map<String, dynamic> params, Options options, CancelToken cancelToken}) async {
    return _request(url, method: PATCH, params: params, options: options, cancelToken: cancelToken);
  }

  Future<dynamic> _request(String url,
      {String method,
      Map<String, dynamic> data,
      Map<String, dynamic> params,
      Options options,
      CancelToken cancelToken,
      ProgressCallback onSendProgress}) async {
//    dio.onHttpClientCreate = (HttpClient client) {
//      client.findProxy = (uri) {
//        //proxy all request to localhost:8888
//        return "PROXY 172.23.235.153:8888";
//      };
//    };
    String errorMsg = "";
    int statusCode;
    Response response;

    //add app source tag
    if (options != null && options.headers == null) {
      options.headers = Map();
    } else if (options == null) {
      options = RequestOptions();
      options.headers = Map();
    }
    options.headers["appName"] = Config.APP_SOURCE;
    options.headers["buildChannel"] = env.channel;
    options.headers["buildType"] = env.buildType;

    if (packageInfo == null) {
      packageInfo = await PackageInfo.fromPlatform();
    }
    options.headers["versionCode"] = packageInfo?.version ?? "" + "+" + packageInfo?.buildNumber ?? "";
    options.headers["time"] = DateTime.now().millisecondsSinceEpoch;
    options.headers["walletAddress"] =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? '';

    // todo rich add userid

    if (method == GET) {
      if (params != null && params.isNotEmpty) {
        StringBuffer sb = new StringBuffer("?");
        params.forEach((key, value) {
          if (value != null) {
            sb.write("$key=$value&");
          }
        });
        String paramStr = sb.toString();
        paramStr = paramStr.substring(0, paramStr.length - 1);
        url += paramStr;
      }
      response = await dio.get(url, options: options, cancelToken: cancelToken);
    } else if (method == POST) {
      if (params != null && params.isNotEmpty) {
        /*params.forEach((key,value){
          print("[base_http] post params.key $key params.values $value");
        });*/
        response = await dio.post(url, data: params, options: options, cancelToken: cancelToken);
      } else if (data != null) {
        response =
            await dio.post(url, data: data, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress);
      } else {
        response = await dio.post(url, options: options, cancelToken: cancelToken);
      }
    } else if (method == PATCH) {
      if (params != null && params.isNotEmpty) {
        response = await dio.patch(url, data: params, options: options, cancelToken: cancelToken);
      } else {
        response = await dio.patch(url, options: options, cancelToken: cancelToken);
      }
    }

    statusCode = response.statusCode;
    if (statusCode < 0) {
      errorMsg = S.of(Keys.rootKey.currentContext).network_request_err(statusCode.toString());
      throw HttpResponseNot200Exception(errorMsg);
    }
//    String res2Json = '{"code":0,"msg":"mssss","data":[{"name":"moo"},{"name":"moo2"}]}';
    if (response.data is Map<String, dynamic>) {
      return response.data;
    }

    Map<String, dynamic> map;
    try {
      map = json.decode(response.data);
    } catch (err) {
      //print('[base_http] json decode 1 err $err');
      //String res2Json = json.encode(response.data);
      try {
        map = json.decode(response.data);
      } catch (err) {
        //print('[base_http] json decode 2 err $err');
      }
    }

    return map ?? response.data;
  }
}
