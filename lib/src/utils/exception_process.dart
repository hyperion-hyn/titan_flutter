import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/global.dart';

class ExceptionProcess {
  static process(Exception error, {bool isThrow = true}) {
    if (error is HttpResponseCodeNotSuccess) {
      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      if (notSuccessError == null) {
        Fluttertoast.showToast(msg: S.of(globalContext).unknown_error_hint);
      } else {
        Fluttertoast.showToast(msg: notSuccessError.message);
      }
    } else if (error is DioError) {
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        Fluttertoast.showToast(msg: S.of(globalContext).net_error_hint);
      }
    }
    if (isThrow) {
      throw e;
    }
  }
}
