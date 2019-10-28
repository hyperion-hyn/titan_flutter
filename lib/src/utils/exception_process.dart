import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/http_exception.dart';

class ExceptionProcess {
  static process(Exception error, {bool isThrow = true}) {
    if (error is HttpResponseCodeNotSuccess) {
      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      if (notSuccessError == null) {
        Fluttertoast.showToast(msg: "未定义错误");
      } else {
        Fluttertoast.showToast(msg: notSuccessError.message);
      }
    } else if (error is DioError) {
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        Fluttertoast.showToast(msg: "网络错误");
      }
    }
    if (isThrow) {
      throw e;
    }
  }
}
