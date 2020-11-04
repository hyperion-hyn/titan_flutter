import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
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

  static toastException(dynamic error) {
    var walletAddr = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ?? "no wallet";
    if (error is HttpResponseCodeNotSuccess) {
      uploadExceptionStr(error.toString(),"HttpResponseCodeNotSuccess $walletAddr");
      if(error.subMsg != null) {
        var rpcReturn = MemoryCache.contractErrorStr(error.subMsg);
        if (rpcReturn != error.subMsg){
          Fluttertoast.showToast(msg: rpcReturn, toastLength: Toast.LENGTH_LONG);
          return;
        }
      }

      if (env.buildType == BuildType.DEV) {
        Fluttertoast.showToast(msg: error.toString());
        return;
      }
      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      if (notSuccessError == null) {
        Fluttertoast.showToast(msg: "${S.of(Keys.rootKey.currentContext).undefind_error} ${error.code}");
      } else {
        Fluttertoast.showToast(msg: notSuccessError.message);
      }
    } else if (error is DioError) {
      uploadExceptionStr(error.toString(),"DioError $walletAddr");
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).network_error);
      }else{
        Fluttertoast.showToast(msg: error.toString());
      }
    } else if (error is PlatformException) {
      uploadExceptionStr(error.toString(),"PlatformException $walletAddr");
      if (error.code == WalletError.PASSWORD_WRONG) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).password_incorrect);
      } else if (error.code == WalletError.PARAMETERS_WRONG) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).param_error);
      } else {
        Fluttertoast.showToast(msg: error.message);
      }
    } else if(error is RPCError){
      uploadExceptionStr(error.toString(),"RPCError $walletAddr");
      Fluttertoast.showToast(
          msg: MemoryCache.contractErrorStr(error.message),
          toastLength: Toast.LENGTH_LONG);
    } else {
      uploadExceptionStr(error.toString(),"OtherError $walletAddr");
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

  static uploadExceptionStr(String exceptionStr, [String errorPrefix]){
    if (env.buildType == BuildType.PROD) {
      FlutterBugly.uploadException(
          message: "[$errorPrefix]: $exceptionStr", detail: "[$errorPrefix]: $exceptionStr");
    }
    logger.e(exceptionStr + errorPrefix);
  }

  static printMessage(dynamic message){
    if (env.buildType != BuildType.PROD) {
      print(message);
    }
  }

}
