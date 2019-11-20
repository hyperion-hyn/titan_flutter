class ValidatorUtil {
  /// 检查是否是邮箱格式
  static bool isEmail(String input) {
    /// 邮箱正则
    String REGEX_EMAIL = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";
    if (input == null || input.isEmpty) return false;
    return new RegExp(REGEX_EMAIL).hasMatch(input);
  }

  static bool validatePassword(String input) {
    if (input == null || input.isEmpty) return false;
//    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    String pattern = r'^.{6,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(input);
  }

  static bool validateNumber(int count, String input) {
    if (input == null || input.isEmpty) return false;
    String pattern = '^\\d{$count}\$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(input);
  }

  static bool validateMoney(String input) {
    if (input == null || input.isEmpty) return false;
    String pattern = r'^([1-9][0-9]*)+(\.[0-9]{1,2})?$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(input);
  }

  static bool validateCode(int count, String input) {
    if (input == null || input.isEmpty) return false;
    String pattern = '^.{$count}\$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(input);
  }
}
