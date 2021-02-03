import 'dart:convert';

import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:titan/src/global.dart';

class MyClient implements Client {
  Client _delegate;

  int _timeout;
  bool _isPrintLog;

  MyClient({Client delegate, isPrintLog = false, int timeout = 5000}) {
    this._delegate = delegate ?? Client();
    this._timeout = timeout;
    this._isPrintLog = isPrintLog;
  }

  @override
  void close() {
    _delegate.close();
  }

  @override
  Future<Response> delete(url, {Map<String, String> headers}) async {
    if (_isPrintLog) {
      logger.i('Request begin [delete] $url');
    }
    var resp =
        await _delegate.delete(url, headers: headers).timeout(Duration(milliseconds: _timeout));
    if (_isPrintLog) {
      logger.i('Response [delete] $url: ${resp.body}');
    }
    return resp;
  }

  @override
  Future<Response> get(url, {Map<String, String> headers}) async {
    if (_isPrintLog) {
      logger.i('Request begin [get] $url');
    }
    var resp = await _delegate.get(url, headers: headers).timeout(Duration(milliseconds: _timeout));
    if (_isPrintLog) {
      logger.i('Response [get] $url: ${resp.body}');
    }
    return resp;
  }

  @override
  Future<Response> head(url, {Map<String, String> headers}) async {
    if (_isPrintLog) {
      logger.i('Request begin [head] $url');
    }
    var resp =
        await _delegate.head(url, headers: headers).timeout(Duration(milliseconds: _timeout));
    if (_isPrintLog) {
      logger.i('Response [head] $url: ${resp.body}');
    }
    return resp;
  }

  @override
  Future<Response> patch(url, {Map<String, String> headers, body, Encoding encoding}) async {
    if (_isPrintLog) {
      logger.i('Request begin [patch] $url');
    }
    var resp = await _delegate
        .patch(url, headers: headers, body: body, encoding: encoding)
        .timeout(Duration(milliseconds: _timeout));
    if (_isPrintLog) {
      logger.i('Response [patch] $url: ${resp.body}');
    }
    return resp;
  }

  @override
  Future<Response> post(url, {Map<String, String> headers, body, Encoding encoding}) async {
    if (_isPrintLog) {
      logger.i('Request begin [post] $url');
    }

    var resp = await _delegate
        .post(url, headers: headers, body: body, encoding: encoding)
        .timeout(Duration(milliseconds: _timeout));
    if (_isPrintLog) {
      logger.i('Response [post] $url: ${resp.body}');
    }
    return resp;
  }

  @override
  Future<Response> put(url, {Map<String, String> headers, body, Encoding encoding}) async {
    if (_isPrintLog) {
      logger.i('Request begin [put] $url');
    }
    var resp = await _delegate
        .put(url, headers: headers, body: body, encoding: encoding)
        .timeout(Duration(milliseconds: _timeout));
    if (_isPrintLog) {
      logger.i('Response [put] $url: ${resp.body}');
    }
    return resp;
  }

  @override
  Future<String> read(url, {Map<String, String> headers}) {
    return _delegate.read(url, headers: headers);
  }

  @override
  Future<Uint8List> readBytes(url, {Map<String, String> headers}) {
    return _delegate.readBytes(url, headers: headers);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _delegate.send(request);
  }
}
