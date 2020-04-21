import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/utils/utile_ui.dart';

class ExceptionProcess {
  static process(dynamic error, {bool isThrow = true}) {
    //logger.e(error);
    if (error is HttpResponseCodeNotSuccess) {
      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      if (notSuccessError == null) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).undefind_error);
      } else {
        UiUtil.toast(notSuccessError.message);
//        Fluttertoast.showToast(msg: notSuccessError.message);
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
}
