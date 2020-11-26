import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/generated/l10n.dart';
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

String shortBlockChainAddress(String address, {int limitCharsLength = 9}) {
  if (address == null || address == "") {
    return "";
  }
  if (address.length <= limitCharsLength) {
    return address;
  }
  return address.substring(0, limitCharsLength) +
      "..." +
      address.substring(address.length - limitCharsLength, address.length);
}

String shortName(String name, {int limitCharsLength = 9}) {
  if (name == null || name == "") {
    return "";
  }
  if (name.length < limitCharsLength) {
    return name;
  }
  return name.substring(0, limitCharsLength) + "...";
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

class DebounceLater {
  Timer _debounceLater;
  Function _fun;

  void debounceInterval(Function fn, [int t = 100]) {
    if (_debounceLater?.isActive == true) {
      _fun = fn;
      return;
    } else if (_fun == null) {
      fn();
    }
    _fun = fn;

    _debounceLater = Timer(Duration(milliseconds: t), () {
      _debounceLater = null;
      if (_fun != null) {
        _fun();
      }
    });
  }
}

Future launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
}

void printAction(dynamic input, {bool isEncode = false}) {
  const encoder = JsonEncoder.withIndent('  ');

  dynamic obj = input;

  print('obj.runtimeType: ${obj.runtimeType}');

  if (isEncode) {
    if (input is String) {
      const decoder = JsonDecoder();
      obj = decoder.convert(input);
    }

    obj = encoder.convert(obj);
  }

  print(obj);
}
