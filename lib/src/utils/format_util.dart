import 'package:intl/intl.dart';
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

  static String formatDate(int timestamp, {bool isSecond = true}) {
    var multiple = isSecond ? 1000 : 1;
    timestamp = timestamp * multiple;
    return DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ?? "";
  }

  static String formatDateCircle(int timestamp, {bool isSecond = true}) {
    return DateFormat("yyyy.MM.dd").format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ?? "";
  }

  static String amountToString(String amount) => FormatUtil.formatNum(double.parse(amount).toInt());

  static double coinBalanceDouble(CoinVo coinVo) {
    return ConvertTokenUnit.weiToDecimal(coinVo?.balance ?? 0, coinVo?.decimals).toDouble();
  }

  static String coinBalanceHumanRead(CoinVo coinVo) {
    return ConvertTokenUnit.weiToDecimal(coinVo?.balance ?? 0, coinVo?.decimals).toString();
  }

  static String coinBalanceHumanReadFormat(CoinVo coinVo) {
    return NumberFormat("#,###,###.######").format(double.parse(coinBalanceHumanRead(coinVo)));
  }
}
