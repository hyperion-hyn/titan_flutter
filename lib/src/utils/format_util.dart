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

  static String stringFormatCoinNum(String numValue) {
    return NumberFormat("#,###.######").format(double.parse(numValue));
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
    if (timestamp <= 0) return "";

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

  static String formatDateStr(String utcStr, {bool isSecond = true}) {
    var date = DateTime.parse(utcStr);
    var format = isSecond ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd";
    return DateFormat(format).format(date) ?? "";
  }

  static String formatDateCircle(int timestamp, {bool isSecond = true}) {
    return DateFormat("yyyy.MM.dd").format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ?? "";
  }

  static String formatUTCDateStr(String utcStr, {bool isSecond = true}) {
    if (utcStr.isEmpty || utcStr == "0") return "";

    var utc = DateTime.parse(utcStr);

    var utcLocal = utc.toLocal();

    var format = isSecond ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd";

    var formatDate = DateFormat(format).format(utcLocal);
    //print("[time] formatDate:$formatDate");

    /*
    var dateTime = DateFormat(format).parse(utcStr, true);
    print("[time] dateTime:$dateTime");

    var dateLocal = dateTime.toLocal();
    print("[time] dateLocal:$dateLocal");

    var local = DateFormat(format).format(dateLocal) ?? "";
    print("[time] dateLocal:$dateLocal");
    */

    return formatDate;
  }

  static String formatMarketOrderDate(int timestamp, {bool isSecond = true}) {
    return DateFormat("HH:mm MM/dd").format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ?? "";
  }

  static String formatTimer(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTimeNum(hour) + ":" + formatTimeNum(minute) + ":" + formatTimeNum(second);
  }

  static String formatTimeNum(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
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

  static String coinBalanceByDecimal(CoinVo coinVo, int decimal) {
    return truncateDecimalNum(
      ConvertTokenUnit.weiToDecimal(coinVo?.balance ?? 0, coinVo?.decimals ?? 0),
      decimal,
    );
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
    if (price == 0) return "0";

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

  static String truncateDecimalNum(Decimal decNum, int decimal) {
    var number = decNum.toDouble();
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) < decimal) {
      var result =
          number.toStringAsFixed(decimal).substring(0, number.toString().lastIndexOf(".") + decimal + 1).toString();
      result = FormatUtil.strClearZero(result);
      return result;
    } else {
      var result = number.toString().substring(0, number.toString().lastIndexOf(".") + decimal + 1).toString();
      result = FormatUtil.strClearZero(result);
      return result;
    }
  }

  static String truncateDoubleNum(double number, int decimal) {
    if (number == null) {
      return null;
    }
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) < decimal) {
      var result =
          number.toStringAsFixed(decimal).substring(0, number.toString().lastIndexOf(".") + decimal + 1).toString();
      return result;
    } else {
      var result = number.toString().substring(0, number.toString().lastIndexOf(".") + decimal + 1).toString();
      return result;
    }
  }

  static String strClearZero(String value) {
    return Decimal.parse(value).toString();
  }

  static String clearScientificCounting(double value) {
    if (value == null) {
      return "";
    }
    return Decimal.parse(value.toString()).toString();
  }

  static String weiToEtherStr(dynamic entityParam){
    if(entityParam == null){
      return entityParam;
    }
    if(entityParam is String){
      return ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(entityParam)).toString();
    }else if(entityParam is int){
      return ConvertTokenUnit.weiToEther(weiInt: entityParam).toString();
    }else{
      return "0";
    }
  }
}
