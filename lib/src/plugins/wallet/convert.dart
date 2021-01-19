import 'package:decimal/decimal.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';

class ConvertTokenUnit {
  static BigInt numToWei(double num, [int decimals = 18]) {
    var dstr = (Decimal.parse('$num') * Decimal.fromInt(10).pow(decimals)).toString();
    return BigInt.parse(dstr);
  }

  @deprecated
  static BigInt decimalToWei(Decimal num, [int decimals = 18]) {
    var dstr = (num * Decimal.fromInt(10).pow(decimals)).toString();
    return BigInt.parse(dstr);
  }

  static BigInt bigintToWei(BigInt num, [int decimals = 18]) {
    return num * BigInt.from(10).pow(decimals);
  }

  static BigInt strToBigInt(String str, [int decimals = 18]) {
    var dStr = ((Decimal?.tryParse(str) ?? Decimal.zero) * Decimal.fromInt(10).pow(decimals)).toString();
    return BigInt?.tryParse(dStr) ?? BigInt.zero;
  }

  static Decimal weiToDecimal(BigInt wei, [int decimals = 18]) {
    return (Decimal.tryParse(wei.toString()) ?? Decimal.fromInt(0)) / Decimal.fromInt(10).pow(decimals);
  }

  static Decimal weiToEther({BigInt weiBigInt, int weiInt}) {
    var wei = weiBigInt != null ? Decimal.parse(weiBigInt.toString()) : Decimal.fromInt(weiInt);
    return wei / Decimal.fromInt(EthereumUnitValue.ETHER);
  }

  static Decimal weiToGWei({BigInt weiBigInt, int weiInt}) {
    var wei = weiBigInt != null ? Decimal.parse(weiBigInt.toString()) : Decimal.fromInt(weiInt);
    return wei / Decimal.fromInt(EthereumUnitValue.G_WEI);
  }

  static BigInt etherToWei({Decimal etherDecimal, double etherDouble}) {
    if (etherDecimal != null) {
      return BigInt.parse((etherDecimal * Decimal.fromInt(EthereumUnitValue.ETHER)).toString());
    } else if (etherDouble != null) {
      return BigInt.parse((Decimal.parse('$etherDouble') * Decimal.fromInt(EthereumUnitValue.ETHER)).toString());
    }
    return BigInt.from(0);
  }

  static BigInt etherToGWei({Decimal etherDecimal, double etherDouble}) {
    if (etherDecimal != null) {
      return BigInt.parse(
          (etherDecimal * Decimal.fromInt(EthereumUnitValue.ETHER) / Decimal.fromInt(EthereumUnitValue.G_WEI))
              .toString());
    } else if (etherDouble != null) {
      return BigInt.parse((Decimal.parse('$etherDouble') *
              Decimal.fromInt(EthereumUnitValue.ETHER) /
              Decimal.fromInt(EthereumUnitValue.G_WEI))
          .toString());
    }
    return BigInt.from(0);
  }
}
