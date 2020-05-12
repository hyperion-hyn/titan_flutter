import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/config/consts.dart';

import '../../env.dart';
import '../global.dart';

class ExceptionProcess {
  static process(Exception error, {bool isThrow = true}) {
    if (error is HttpResponseCodeNotSuccess) {
      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      if (notSuccessError == null) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).undefind_error);
      } else {
        Fluttertoast.showToast(msg: notSuccessError.message);
      }
    } else if (error is DioError) {
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).network_error);
      }
    }
    if (isThrow) {
      throw e;
    }
  }

  static uploadPoiException(dynamic exception, [String errorPrefix]) {
    if (env.buildType == BuildType.PROD) {
      if (exception is Error) {
        FlutterBugly.uploadException(
            message: "[$errorPrefix]: ${exception.stackTrace}", detail: "[$errorPrefix]: ${exception.stackTrace}");
      } else {
        FlutterBugly.uploadException(
            message: "[$errorPrefix]: ${exception.toString()}", detail: "[$errorPrefix]: ${exception.toString()}");
      }
    }
    logger.e(exception);
  }
}
