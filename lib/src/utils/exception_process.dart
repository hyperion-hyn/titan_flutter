import 'dart:math';

import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/utils/utile_ui.dart';

class ExceptionProcess {
  static process(dynamic error, {bool isThrow = true}) {
    //logger.e(error);
    if (error is HttpResponseCodeNotSuccess) {
      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      if (notSuccessError == null) {
        UiUtil.toast(S.of(Keys.rootKey.currentContext).unknown_error_hint);
//        Fluttertoast.showToast(msg: S.of(globalContext).unknown_error_hint);
      } else {
        UiUtil.toast(notSuccessError.message);
//        Fluttertoast.showToast(msg: notSuccessError.message);
      }
    } else if (error is DioError) {
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        UiUtil.toast(S.of(Keys.rootKey.currentContext).net_error_hint);
//        Fluttertoast.showToast(msg: S.of(globalContext).net_error_hint);
      }
    }
    if (isThrow) {
      throw e;
    }
  }
}
