import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/consts/consts.dart';

import '../../../env.dart';
import 'entity.dart';
import 'http_exception.dart';

class BaseHttpCore {
  final Dio dio;

  BaseHttpCore(this.dio);

  static const String GET = "get";
  static const String POST = "post";

  Future<ResponseEntity<T>> getResponseEntity<T>(String url, EntityFactory<T> factory,
      {Map<String, dynamic> params}) async {
    var res = await get(url, params: params);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  Future<ResponseEntity<T>> postResponseEntity<T>(String url, EntityFactory<T> factory,
      {Map<String, dynamic> params}) async {
    var res = await post(url, params: params);
    var responseEntity = ResponseEntity<T>.fromJson(res, factory: factory);
    return responseEntity;
  }

  Future<T> getEntity<T>(String url, EntityFactory<T> factory, {Map<String, dynamic> params}) async {
    var responseEntity = await getResponseEntity<T>(url, factory, params: params);
    if (responseEntity.code != ResponseCode.SUCCESS) {
      throw HttpResponseCodeNotSuccess(responseEntity.msg);
    }
    return responseEntity.data;
  }

  Future<T> postEntity<T>(String url, EntityFactory<T> factory, {Map<String, dynamic> params}) async {
    var responseEntity = await postResponseEntity<T>(url, factory, params: params);
    if (responseEntity.code != ResponseCode.SUCCESS) {
      throw HttpResponseCodeNotSuccess(responseEntity.msg);
    }
    return responseEntity.data;
  }

  //get method
  Future<dynamic> get(String url, {Map<String, dynamic> params}) async {
    return _request(url, method: GET, params: params);
  }

  //post method
  Future<dynamic> post(String url, {Map<String, dynamic> params}) async {
    return _request(url, method: POST, params: params);
  }

  Future<dynamic> _request(String url, {String method, Map<String, dynamic> params}) async {
//    dio.onHttpClientCreate = (HttpClient client) {
//      client.findProxy = (uri) {
//        //proxy all request to localhost:8888
//        return "PROXY 172.23.235.153:8888";
//      };
//    };
    String errorMsg = "";
    int statusCode;
    Response response;
    if (method == GET) {
      if (params != null && params.isNotEmpty) {
        StringBuffer sb = new StringBuffer("?");
        params.forEach((key, value) {
          sb.write("$key=$value&");
        });
        String paramStr = sb.toString();
        paramStr = paramStr.substring(0, paramStr.length - 1);
        url += paramStr;
      }
      response = await dio.get(url);
    } else if (method == POST) {
      if (params != null && params.isNotEmpty) {
        response = await dio.post(url, data: params);
      } else {
        response = await dio.post(url);
      }
    }

    statusCode = response.statusCode;
    if (statusCode < 0) {
      errorMsg = S.of(Keys.mainContextKey.currentContext).network_request_err(statusCode.toString());
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
      print('json decode 1 err $err');
      String res2Json = json.encode(response.data);
      try {
        map = json.decode(response.data);
      } catch (err) {
        print('json decode 2 err $err');
      }
    }

    return map ?? response.data;
  }
}
