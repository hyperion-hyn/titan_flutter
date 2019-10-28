import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/generated/i18n.dart';
import 'package:url_launcher/url_launcher.dart';

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
  if (address == null || address == "") {
    return "";
  }
  if (address.length < 9) {
    return address;
  }
  return address.substring(0, 9) + "..." + address.substring(address.length - 9, address.length);
}

String shortEmail(String email) {
  if (email == null || email == "") {
    return "";
  }

  int atIconIndex = email.indexOf("@");
  if (atIconIndex < 3) {
    return email;
  }
  return email.substring(0, 3) + "*" + email.substring(atIconIndex);
}

///防抖动
///RaisedButton(
//      onPressed: debounce(() {
//          print(1);
//     }, 3000),
//    child: Text('Test'),
//)
Timer _debounce;

Function debounce(Function fn, [int t = 100]) {
  return () {
    // 还在时间之内，抛弃上一次
    if (_debounce?.isActive ?? false) _debounce.cancel();

    _debounce = Timer(Duration(milliseconds: t), () {
      fn();
    });
  };
}

Future launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
}

class Utils {

  /// 后台算力单位转成UI显示单位
  static double powerForShow(int power) {
    return power / 10.0;
  }

}
