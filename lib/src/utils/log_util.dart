import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/error/base_error.dart';
import 'package:titan/src/basic/error/error_code.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
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

  static toastException(dynamic error,{dynamic stack = ""}) {
    var walletAddr =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet?.getEthAccount()?.address ??
            "no wallet";
    if (error is HttpResponseCodeNotSuccess) {
      uploadExceptionStr("${error.toString()} Stack: $stack", "HttpResponseCodeNotSuccess $walletAddr");
      if (error.subMsg != null) {
        var rpcReturn = MemoryCache.contractErrorStr(error.subMsg);
        if (rpcReturn != error.subMsg) {
          Fluttertoast.showToast(
            msg: rpcReturn,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
          return;
        }

        var atlasReturn = BaseError.getChainErrorReturn(error.subMsg);
        if (atlasReturn != error.subMsg) {
          Fluttertoast.showToast(
            msg: "$atlasReturn",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
          return;
        }
      }

      HttpResponseCodeNotSuccess notSuccessError = NOT_SUCCESS_ERROR_CODE_MAP[error.code];
      if (notSuccessError == null) {
        if (env.buildType == BuildType.DEV) {
          Fluttertoast.showToast(msg: error.toString());
          return;
        }
        Fluttertoast.showToast(msg: "${S.of(Keys.rootKey.currentContext).undefind_error} ${error.code}");
      } else {
        Fluttertoast.showToast(
          msg: notSuccessError.message,
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (error is DioError) {
      uploadExceptionStr("${error.toString()} Stack: $stack", "DioError $walletAddr");
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        Fluttertoast.showToast(
          msg: S.of(Keys.rootKey.currentContext).network_error,
          gravity: ToastGravity.CENTER,
        );
      } else {
        Fluttertoast.showToast(
          msg: error.toString(),
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (error is PlatformException) {
      uploadExceptionStr("${error.toString()} Stack: $stack", "PlatformException $walletAddr");
      if (error.code == ErrorCode.PASSWORD_WRONG) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).password_incorrect);
      } else if (error.code == ErrorCode.PARAMETERS_WRONG) {
        Fluttertoast.showToast(msg: S.of(Keys.rootKey.currentContext).param_error);
      } else {
        Fluttertoast.showToast(
          msg: error.message,
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (error is RPCError) {
      uploadExceptionStr("${error.toString()} Stack: $stack", "RPCError $walletAddr");
      Fluttertoast.showToast(
        msg: MemoryCache.contractErrorStr(error.message),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    } else {
      uploadExceptionStr("${error.toString()} Stack: $stack", "OtherError $walletAddr");
      Fluttertoast.showToast(
        msg: error.toString(),
        gravity: ToastGravity.CENTER,
      );
    }
  }

  static uploadException(dynamic exception, [String errorPrefix = 'error']) {
    if (exception is Error) {
      logger.e("[$errorPrefix]: ${exception.stackTrace}");
    } else {
      logger.e("[$errorPrefix]: ${exception?.toString()}");
    }
  }

  static uploadExceptionStr(String exceptionStr, [String errorPrefix]) {
    logger.e("$exceptionStr  $errorPrefix");
  }

  static printMessage(dynamic message) {
    if (showLog) {
      print(message);
    }
  }
}
