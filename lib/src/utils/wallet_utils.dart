

import 'package:intl/intl.dart';

class WalletUtils{

  static String formatCoinNum(double coinNum) {
    return NumberFormat("#,###.######").format(coinNum);
  }

  static String formatPrice(double price) {
    if(price >= 1){
      return NumberFormat("#,###.##").format(price);
    }else{
      return NumberFormat("#,###.####").format(price);
    }
  }

  static String formatPercentChange(double percentChange) {
    return NumberFormat("#,###.##").format(percentChange) + "%";
  }
}