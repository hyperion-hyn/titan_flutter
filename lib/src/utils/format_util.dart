import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'dart:convert';

import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/plugins/wallet/convert.dart';

class FormatUtil {
  static String formatNum(int numValue) {
    return NumberFormat("#,###,###,###").format(numValue);
  }

  static String stringFormatNum(String numValue) {
    return NumberFormat("#,###,###,###").format(int.parse(numValue));
  }

  static String doubleFormatNum(double numValue) {
    return NumberFormat("#,###,###,###").format(numValue);
  }

  static String formatNumDecimal(double numValue) {
    return NumberFormat("#,###,###,###.####").format(numValue);
  }

  static String formatPercent(double doubleValue) {
    doubleValue = doubleValue * 100;
    return NumberFormat("#,###.##").format(doubleValue) + "%";
  }

  static String formatTenThousand(String strValue) {
    var doubleValue = double.parse(strValue) / 10000;
    return NumberFormat("#,###,###,###").format(doubleValue) + "万";
  }

  static String formatTenThousandNoUnit(String strValue) {
    var doubleValue = double.parse(strValue) / 10000;
    return NumberFormat("#,###,###,###").format(doubleValue);
  }

  static String formatDate(int timestamp, {bool isSecond = false, bool isMillisecond = false}) {
    var format = isSecond ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd";
    if (!isMillisecond) {
      timestamp = timestamp * 1000;
    }

    var date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
    //print("[format]   timestamp:$timestamp, date:$date");

    return DateFormat(format).format(date) ?? "";
  }

  static String formatSecondDate(int timestamp) {
    var format = "HH:mm:ss";

    var date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
    //print("[format]   timestamp:$timestamp, date:$date");

    return DateFormat(format).format(date) ?? "";
  }

  static String formatDateCircle(int timestamp, {bool isSecond = true}) {
    return DateFormat("yyyy.MM.dd").format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ?? "";
  }

  static String formatMarketOrderDate(int timestamp, {bool isSecond = true}) {
    return DateFormat("HH:mm MM/dd").format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ?? "";
  }

  static String amountToString(String amount) => FormatUtil.formatNum(double.parse(amount).toInt());

  static String encodeBase64(String data) {
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

  static String decodeBase64(String data) {
    return String.fromCharCodes(base64Decode(data));
  }

  static double coinBalanceDouble(CoinVo coinVo) {
    return ConvertTokenUnit.weiToDecimal(coinVo?.balance ?? 0, coinVo?.decimals ?? 0).toDouble();
  }

  static String coinBalanceHumanRead(CoinVo coinVo) {
    return ConvertTokenUnit.weiToDecimal(coinVo?.balance ?? 0, coinVo?.decimals ?? 0).toString();
  }

  static String coinBalanceHumanReadFormat(CoinVo coinVo, [isFloor = true]) {
    var value = double.parse(coinBalanceHumanRead(coinVo));
    if (isFloor) {
      value = (value * 1000000).floor() / 1000000;
    }
    return NumberFormat("#,###,###.######").format(value);
  }

  static String formatCoinNum(double coinNum, [isFloor = true]) {
    if (isFloor) {
      coinNum = (coinNum * 1000000).floor() / 1000000;
    }
    return NumberFormat("#,###.######").format(coinNum);
  }

  static String formatPrice(double price, [isFloor = true]) {
    if (price >= 1) {
      if (isFloor) {
        price = (price * 100).floor() / 100;
      }
      return NumberFormat("#,###.##").format(price);
    } else {
      if (isFloor) {
        price = (price * 10000).floor() / 10000;
      }
      return NumberFormat("#,###.####").format(price);
    }
  }

  static String formatPercentChange(double percentChange) {
    return NumberFormat("#,###.##").format(percentChange) + "%";
  }

  static String timeString(BuildContext context, double seconds) {
    if (seconds < 60) {
      return S.of(context).less_than_1_min;
    }
    final kDay = 3600 * 24;
    final kHour = 3600;
    final kMinute = 60;
    int day = 0;
    int hour = 0;
    int minute = 0;
    if (seconds > kDay) {
      day = seconds ~/ kDay;
      seconds = seconds - day * kDay;
    }
    if (seconds > kHour) {
      hour = seconds ~/ kHour;
      seconds = seconds - hour * kHour;
    }
    minute = seconds ~/ kMinute;
    seconds = seconds - minute * kMinute;

    var timeStr = '';
    if (day > 0) {
      timeStr += S.of(context).n_day('$day');
    }
    if (hour > 0) {
      timeStr += S.of(context).n_hour('$hour');
    }
    if (minute > 0) {
      timeStr += S.of(context).n_minute('$minute');
    }
    return timeStr;
  }

  static String timeStringSimple(BuildContext context, double seconds) {
    if (seconds < 60) {
      return S.of(context).n_second('$seconds');
    }
    final kDay = 3600 * 24;
    final kHour = 3600;
    final kMinute = 60;
    int day = 0;
    int hour = 0;
    int minute = 0;
    if (seconds > kDay) {
      day = seconds ~/ kDay;
      seconds = seconds - day * kDay;
    }
    if (seconds > kHour) {
      hour = seconds ~/ kHour;
      seconds = seconds - hour * kHour;
    }
    minute = seconds ~/ kMinute;
    seconds = seconds - minute * kMinute;

    var timeStr = '';
    if (day > 0) {
      timeStr += S.of(context).n_day('$day');
      timeStr += S.of(context).n_hour_simple('$hour');
      return timeStr;
    }

    if (hour > 0) {
      timeStr += S.of(context).n_hour_simple('$hour');
    }
    if (minute > 0) {
      timeStr += S.of(context).n_minute_simple('$minute');
    }
    return timeStr;
  }

  static String truncateDecimalNum(Decimal number, int decimal) {
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) < decimal) {
      var result =
          number.toStringAsFixed(decimal).substring(0, number.toString().lastIndexOf(".") + decimal + 1).toString();
      return result;
    } else {
      var result = number.toString().substring(0, number.toString().lastIndexOf(".") + decimal + 1).toString();
      return result;
    }
  }
}
