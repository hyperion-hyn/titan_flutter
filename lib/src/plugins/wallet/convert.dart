import 'package:decimal/decimal.dart';

class Convert {
  static BigInt numToWei(double num, [int decimals = 18]) {
    var dstr =
        (Decimal.parse('$num') * Decimal.fromInt(10).pow(decimals)).toString();
    return BigInt.parse(dstr);
  }

//  static BigInt bigIntToWei(BigInt num, [int decimals = 18]) {
//    return num ~/ BigInt.from(10).pow(decimals);
//  }

  static Decimal weiToNum(BigInt wei, [int decimals = 18]) {
    return Decimal.parse(wei.toString()) / Decimal.fromInt(10).pow(decimals);
  }
}
