
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/utils/format_util.dart';

class Map3NodeUtil {

  // input

  static String getManegerTip(NodeItem contract, double inputValue) {
    if (contract == null) return "*";

    double doubleSpendManager = (double.parse(contract.minTotalDelegation) - inputValue) *
        contract.annualizedYield *
        contract.duration /
        365 *
        contract.commission;
    return FormatUtil.formatNumDecimal(doubleSpendManager);
  }

  // output

  static String spendManagerTip(NodeItem contract, double inputValue) {
    if (contract == null) return "*";

    double tip = (inputValue) *
        contract.annualizedYield *
        contract.duration /
        365 *
        contract.commission;
    return FormatUtil.formatNumDecimal(tip);
  }

  // expect yeild

  static String getExpectYield(NodeItem contract, double inputValue) {
    if (contract == null) return "*";

    double out = (inputValue) *
        contract.annualizedYield *
        contract.duration /
        365;
    return FormatUtil.formatNumDecimal(out);
  }

  // profit
  static String getEndProfit(NodeItem contract, double inputValue) {
    if (contract == null) return FormatUtil.formatNumDecimal(inputValue);

    double profit =
        inputValue * (contract.annualizedYield) * contract.duration / 365 + inputValue;
    return FormatUtil.formatNumDecimal(profit);
  }

}