import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:web3dart/json_rpc.dart';

import '../../env.dart';
import '../global.dart';

class LogUtil {
  static process(Exception error) {
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
  }

  static toastException(Exception error) {
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
      }else{
        Fluttertoast.showToast(msg: error.toString());
      }
    } else if (error is PlatformException) {
      if (error.code == WalletError.PASSWORD_WRONG) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).password_incorrect);
      } else if (error.code == WalletError.PARAMETERS_WRONG) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).param_error);
      } else {
        Fluttertoast.showToast(msg: error.message);
      }
    } else if(error is RPCError){
      Fluttertoast.showToast(msg: error.message);
    } else {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  static uploadException(dynamic exception, [String errorPrefix]) {
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

  static printMessage(dynamic message){
    if (env.buildType != BuildType.PROD) {
      print(message);
    }
  }

}
