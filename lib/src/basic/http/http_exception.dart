import 'package:titan/generated/i18n.dart';
import 'package:titan/src/global.dart';

class HttpResponseNot200Exception implements Exception {
  String cause;

  HttpResponseNot200Exception(this.cause);

  @override
  String toString() {
    return "HttpResponseNot200Exception: $cause";
  }
}

class HttpResponseCodeNotSuccess implements Exception {
  int code;
  String message;

  HttpResponseCodeNotSuccess(this.code, this.message);

  @override
  String toString() {
    return "HttpResponseCodeNotSuccess: {message:$message,code:$code}";
  }
}

////通用错误
//var ERROR_UNKNOWN = HttpResponseCodeNotSuccess(-10000, "Unknown error"); //未知错误
//var ERROR_PARAMETER = HttpResponseCodeNotSuccess(-10001, "Invalid request params"); //参数错误
//var ERROR_UNAUTHORIZED = HttpResponseCodeNotSuccess(-10002, "unauthorized");
//var ERROR_ACCESS_DENIED = HttpResponseCodeNotSuccess(-1003, "access denied");
//var CONTENT_CONFLICT = HttpResponseCodeNotSuccess(-1004, "Content conflict");
//var NO_CONTENT = HttpResponseCodeNotSuccess(-1005, "Not content");
//var NETWORK_ERROR = HttpResponseCodeNotSuccess(-1006, "network error");
//final HttpResponseCodeNotSuccess ERROR_USER_CREATED = HttpResponseCodeNotSuccess(-20001, "create user error"); //用户创建失败
//var ERROR_USER_EXIST = HttpResponseCodeNotSuccess(-20002, "user already exist"); //用户已存在
//var ERROR_USER_UPATED = HttpResponseCodeNotSuccess(-20004, "update user error"); //用户更新失败
//var ERROR_VERIFICATION_CODE = HttpResponseCodeNotSuccess(-20005, "incorrect verification code"); //验证码错误
//var ERROR_INVITATION_CODE = HttpResponseCodeNotSuccess(-20006, "incorrect invitation code"); //邀请码错误
//var ERROR_LOGIN = HttpResponseCodeNotSuccess(-20007, "fail to login"); //登录错误
//var ERROR_RESET_PASSWORD = HttpResponseCodeNotSuccess(-20008, "fail to reset password"); //重置密码错误
//var ERROR_CHECK_IN_LIMIT = HttpResponseCodeNotSuccess(-20009, "check-in reach the upper limit"); //签到达到上限
//var ERROR_CHECK_IN_INTERVAL = HttpResponseCodeNotSuccess(-20010, "check-in interval is 30 minutes."); //签到时间间隔var

var ERROR_OUT_OF_RANGE = HttpResponseCodeNotSuccess(-1007, S.of(globalContext).over_limit_hint);

var ERROR_FUND_PASSWORD = HttpResponseCodeNotSuccess(-20011, S.of(globalContext).fund_pwd_error_hint); //签到时间间隔var

List<HttpResponseCodeNotSuccess> NOT_SUCCESS_ERROR_CODE_LIST = [
  HttpResponseCodeNotSuccess(-10000, S.of(globalContext).unknown_error_hint),
  HttpResponseCodeNotSuccess(-10001, S.of(globalContext).para_error_hint),
  HttpResponseCodeNotSuccess(-10002, S.of(globalContext).unauthorized),
  HttpResponseCodeNotSuccess(-1003, S.of(globalContext).insufficient_permission_hint),
  HttpResponseCodeNotSuccess(-1004, S.of(globalContext).content_conflict_hint),
  HttpResponseCodeNotSuccess(-1005, S.of(globalContext).no_content_hint),
  HttpResponseCodeNotSuccess(-1006, S.of(globalContext).net_error_hint),
  ERROR_OUT_OF_RANGE,
  HttpResponseCodeNotSuccess(-20001, S.of(globalContext).create_user_fail_hint),
  HttpResponseCodeNotSuccess(-20002, S.of(globalContext).account_exist_hint),
  HttpResponseCodeNotSuccess(-20004, S.of(globalContext).update_user_info_fail_hint),
  HttpResponseCodeNotSuccess(-20005, S.of(globalContext).verify_code_error_hint),
  HttpResponseCodeNotSuccess(-20006, S.of(globalContext).invite_code_error_hint),
  HttpResponseCodeNotSuccess(-20007, S.of(globalContext).username_pwd_not_match_hint),
  HttpResponseCodeNotSuccess(-20008, S.of(globalContext).psw_reset_error_hint),
  HttpResponseCodeNotSuccess(-20009, S.of(globalContext).today_complete_hint),
  HttpResponseCodeNotSuccess(-20010, S.of(globalContext).task_interval_below_limit),
  ERROR_FUND_PASSWORD
];

Map<int, HttpResponseCodeNotSuccess> NOT_SUCCESS_ERROR_CODE_MAP =
    Map.fromIterable(NOT_SUCCESS_ERROR_CODE_LIST, key: (errorTemp) => errorTemp.code, value: (errorTemp) => errorTemp);
