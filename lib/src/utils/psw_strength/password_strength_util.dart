import 'bruteforce.dart';
import 'common.dart';

class PasswordStrengthUtil {

  /// Estimates the strength of a password.
  /// Returns a [double] between `0.0` and `1.0`, inclusive.
  /// A value of `0.0` means the given [password] is extremely weak,
  /// while a value of `1.0` means it is especially strong.
  static double estimatePasswordStrength(String password, {limitLength = 0}) {
    return estimateBruteforceStrength(password, limitLength: limitLength) *
        estimateCommonDictionaryStrength(password);
  }

  static int getPasswordLevel(String password, {limitLength = 0}) {
    double strengthValue =
    estimatePasswordStrength(password, limitLength: limitLength);
    if (strengthValue <= 0) {
      return 0;
    } else if (strengthValue > 0 && strengthValue <= 0.25) {
      return 1;
    } else if (strengthValue > 0.25 && strengthValue <= 0.5) {
      return 2;
    } else if (strengthValue > 0.5 && strengthValue <= 0.75) {
      return 3;
    } else if (strengthValue > 0.75 && strengthValue <= 1) {
      return 4;
    }
    return 0;
  }
}