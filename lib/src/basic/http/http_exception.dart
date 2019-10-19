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
//var ERROR_OUT_OF_RANGE = HttpResponseCodeNotSuccess(-1007, "out of range");
//final HttpResponseCodeNotSuccess ERROR_USER_CREATED = HttpResponseCodeNotSuccess(-20001, "create user error"); //用户创建失败
//var ERROR_USER_EXIST = HttpResponseCodeNotSuccess(-20002, "user already exist"); //用户已存在
//var ERROR_USER_UPATED = HttpResponseCodeNotSuccess(-20004, "update user error"); //用户更新失败
//var ERROR_VERIFICATION_CODE = HttpResponseCodeNotSuccess(-20005, "incorrect verification code"); //验证码错误
//var ERROR_INVITATION_CODE = HttpResponseCodeNotSuccess(-20006, "incorrect invitation code"); //邀请码错误
//var ERROR_LOGIN = HttpResponseCodeNotSuccess(-20007, "fail to login"); //登录错误
//var ERROR_RESET_PASSWORD = HttpResponseCodeNotSuccess(-20008, "fail to reset password"); //重置密码错误
//var ERROR_CHECK_IN_LIMIT = HttpResponseCodeNotSuccess(-20009, "check-in reach the upper limit"); //签到达到上限
//var ERROR_CHECK_IN_INTERVAL = HttpResponseCodeNotSuccess(-20010, "check-in interval is 30 minutes."); //签到时间间隔var
var ERROR_FUND_PASSWORD = HttpResponseCodeNotSuccess(-20011, "资金密码错误"); //签到时间间隔var

List<HttpResponseCodeNotSuccess> NOT_SUCCESS_ERROR_CODE_LIST = [
  HttpResponseCodeNotSuccess(-10000, "未知错误"),
  HttpResponseCodeNotSuccess(-10001, "参数错误"),
  HttpResponseCodeNotSuccess(-10002, "未授权"),
  HttpResponseCodeNotSuccess(-1003, "权限不足"),
  HttpResponseCodeNotSuccess(-1004, "内容冲突"),
  HttpResponseCodeNotSuccess(-1005, "无内容"),
  HttpResponseCodeNotSuccess(-1006, "网络错误"),
  HttpResponseCodeNotSuccess(-1007, "超过范围"),
  HttpResponseCodeNotSuccess(-20001, "创建用户失败"),
  HttpResponseCodeNotSuccess(-20002, "用户已存在"),
  HttpResponseCodeNotSuccess(-20004, "更新用户信息失败"),
  HttpResponseCodeNotSuccess(-20005, "验证码错误"),
  HttpResponseCodeNotSuccess(-20006, "邀请码错误"),
  HttpResponseCodeNotSuccess(-20007, "登录错误"),
  HttpResponseCodeNotSuccess(-20008, "重置密码错误"),
  HttpResponseCodeNotSuccess(-20009, "今天打卡任务已完成，请明日再来"),
  HttpResponseCodeNotSuccess(-20010, "打卡间隔低于30分钟"),
  ERROR_FUND_PASSWORD
];

Map<int, HttpResponseCodeNotSuccess> NOT_SUCCESS_ERROR_CODE_MAP =
    Map.fromIterable(NOT_SUCCESS_ERROR_CODE_LIST, key: (errorTemp) => errorTemp.code, value: (errorTemp) => errorTemp);
