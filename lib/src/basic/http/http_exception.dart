import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';

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
  String subMsg;

  HttpResponseCodeNotSuccess(this.code, this.message,{this.subMsg});

  @override
  String toString() {
    return "HttpResponseCodeNotSuccess: {message:$message,code:$code,subMsg:$subMsg}";
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
var ERROR_OUT_OF_RANGE = HttpResponseCodeNotSuccess(
    -1007, S.of(Keys.rootKey.currentContext).exceed_the_limit);
//final HttpResponseCodeNotSuccess ERROR_USER_CREATED = HttpResponseCodeNotSuccess(-20001, "create user error"); //用户创建失败
//var ERROR_USER_EXIST = HttpResponseCodeNotSuccess(-20002, "user already exist"); //用户已存在
//var ERROR_USER_UPATED = HttpResponseCodeNotSuccess(-20004, "update user error"); //用户更新失败
//var ERROR_VERIFICATION_CODE = HttpResponseCodeNotSuccess(-20005, "incorrect verification code"); //验证码错误
//var ERROR_INVITATION_CODE = HttpResponseCodeNotSuccess(-20006, "incorrect invitation code"); //邀请码错误
//var ERROR_LOGIN = HttpResponseCodeNotSuccess(-20007, "fail to login"); //登录错误
//var ERROR_RESET_PASSWORD = HttpResponseCodeNotSuccess(-20008, "fail to reset password"); //重置密码错误
//var ERROR_CHECK_IN_LIMIT = HttpResponseCodeNotSuccess(-20009, "check-in reach the upper limit"); //签到达到上限
//var ERROR_CHECK_IN_INTERVAL = HttpResponseCodeNotSuccess(-20010, "check-in interval is 30 minutes."); //签到时间间隔var
var ERROR_FUND_PASSWORD = HttpResponseCodeNotSuccess(
  -20011,
  S.of(Keys.rootKey.currentContext).fund_password_error,
); //签到时间间隔var

List<HttpResponseCodeNotSuccess> NOT_SUCCESS_ERROR_CODE_LIST = [
  HttpResponseCodeNotSuccess(
    -10000,
    S.of(Keys.rootKey.currentContext).unknown_error,
  ),
  HttpResponseCodeNotSuccess(
    -10001,
    S.of(Keys.rootKey.currentContext).param_error,
  ),
  HttpResponseCodeNotSuccess(
    -10002,
    S.of(Keys.rootKey.currentContext).unauthorized,
  ),
  HttpResponseCodeNotSuccess(
    -1003,
    S.of(Keys.rootKey.currentContext).insufficient_permission,
  ),
  HttpResponseCodeNotSuccess(
    -1004,
    S.of(Keys.rootKey.currentContext).content_conflict,
  ),
  HttpResponseCodeNotSuccess(
    -1005,
    S.of(Keys.rootKey.currentContext).no_content,
  ),
  HttpResponseCodeNotSuccess(
    -1006,
    S.of(Keys.rootKey.currentContext).network_error,
  ),
  ERROR_OUT_OF_RANGE,
  HttpResponseCodeNotSuccess(
    -2005,
    S.of(Keys.rootKey.currentContext).agreed_invitation_cannot_invite_again,
  ),
  HttpResponseCodeNotSuccess(
    -2006,
    S.of(Keys.rootKey.currentContext).already_your_friend_cannot_be_referrer,
  ),
  HttpResponseCodeNotSuccess(
    -2007,
    S.of(Keys.rootKey.currentContext).invitations_number_full,
  ),
  HttpResponseCodeNotSuccess(
    -3001,
    S.of(Keys.rootKey.currentContext).transaction_progress_try_again,
  ),
  HttpResponseCodeNotSuccess(
    -20001,
    S.of(Keys.rootKey.currentContext).create_account_fail,
  ),
  HttpResponseCodeNotSuccess(
    -20002,
    S.of(Keys.rootKey.currentContext).account_exist_direct_login,
  ),
  HttpResponseCodeNotSuccess(
    -20004,
    S.of(Keys.rootKey.currentContext).update_user_info_fail,
  ),
  HttpResponseCodeNotSuccess(
    -20005,
    S.of(Keys.rootKey.currentContext).verification_code_error,
  ),
  HttpResponseCodeNotSuccess(
    -20006,
    S.of(Keys.rootKey.currentContext).invitation_code_error,
  ),
  HttpResponseCodeNotSuccess(
    -20007,
    S.of(Keys.rootKey.currentContext).username_and_password_not_match,
  ),
  HttpResponseCodeNotSuccess(
    -20008,
    S.of(Keys.rootKey.currentContext).password_reset_error,
  ),
  HttpResponseCodeNotSuccess(
    -20009,
    S.of(Keys.rootKey.currentContext).punch_card_completed_came_tomorrow,
  ),
  HttpResponseCodeNotSuccess(
    -20010,
    S.of(Keys.rootKey.currentContext).check_interval_less_thirty_minutes,
  ),
  HttpResponseCodeNotSuccess(
    -30011,
    S.of(Keys.rootKey.currentContext).hyn_balance_not_enough_gas,
  ),
  HttpResponseCodeNotSuccess(
    -30012,
    S.of(Keys.rootKey.currentContext).rp_balance_not_enoungh,
  ),
  HttpResponseCodeNotSuccess(
    -30013,
    'Insufficient HT for gas fee',
  ),
  HttpResponseCodeNotSuccess(
    -40001,
    S.of(Keys.rootKey.currentContext).red_pocket_not_ready,
  ),
  HttpResponseCodeNotSuccess(
    -40002,
    S.of(Keys.rootKey.currentContext).red_pocket_expired,
  ),
  HttpResponseCodeNotSuccess(
    -40003,
    S.of(Keys.rootKey.currentContext).red_pocket_run_out,
  ),
  HttpResponseCodeNotSuccess(
    -40004,
    S.of(Keys.rootKey.currentContext).not_new_user,
  ),
  HttpResponseCodeNotSuccess(
    -40005,
    S.of(Keys.rootKey.currentContext).too_far_from_red_pocket,
  ),
  HttpResponseCodeNotSuccess(
    -40006,
    S.of(Keys.rootKey.currentContext).key_word_not_corrct,
  ),
  HttpResponseCodeNotSuccess(
    -40007,
    S.of(Keys.rootKey.currentContext).rp_amount_less_than_min,
  ),
  HttpResponseCodeNotSuccess(
    -40008,
    S.of(Keys.rootKey.currentContext).hyn_amount_less_than_min,
  ),
  HttpResponseCodeNotSuccess(
    -40009,
    S.of(Keys.rootKey.currentContext).red_pocket_already_token,
  ),
  HttpResponseCodeNotSuccess(
    -40012,
    S.of(Keys.rootKey.currentContext).can_not_collect_your_own_new_red_pocket,
  ),
  ERROR_FUND_PASSWORD
];

Map<int, HttpResponseCodeNotSuccess> NOT_SUCCESS_ERROR_CODE_MAP =
    Map.fromIterable(
  NOT_SUCCESS_ERROR_CODE_LIST,
  key: (errorTemp) => errorTemp.code,
  value: (errorTemp) => errorTemp,
);

const ERROR_CODE_EXCHANGE_NOT_LOGIN = 205;
