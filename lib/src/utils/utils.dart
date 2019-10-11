import 'package:flutter/cupertino.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/generated/i18n.dart';

String getExpiredTimeShowTip(BuildContext context, int expireTime) {
  var timeLeft = (expireTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
  var day = 3600 * 24;
  var hour = 3600;
  var minute = 60;
  if (timeLeft > day) {
    return sprintf(S.of(context).refresh_public_key_days_tips, [timeLeft ~/ day]);
  } else if (timeLeft > hour) {
    var hours = timeLeft ~/ hour;
    var minutes = (timeLeft - hours * hour) ~/ 60;
    return sprintf(S.of(context).refresh_public_key_hours_tips, [hours, minutes]);
  } else if (timeLeft > minute) {
    var minutes = timeLeft ~/ 60;
    return sprintf(S.of(context).refresh_public_key_minutes_tips, [minutes]);
  } else if (timeLeft > 0) {
    return sprintf(S.of(context).refresh_public_key_seconds_tips, [timeLeft]);
  } else {
    return S.of(context).generating_key;
  }
}

String shortEthAddress(String address) {
  return address.substring(0, 9) + "..." + address.substring(address.length - 9, address.length);
}
