
import 'dart:ui';

import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/utils/format_util.dart';

class Map3NodeUtil {

  // input

  static String getManagerTip(NodeItem contract, double inputValue) {
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

  static String managerTip(NodeItem contract, double inputValue, {bool isOwner = false}) {
    if (contract == null) return "*";

    return isOwner?getManagerTip(contract, inputValue):spendManagerTip(contract, inputValue);
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

  static HexColor stateColor(ContractState state) {
    if (state == null) return HexColor('#1FB9C7');

    Color statusColor = HexColor('#EED197');

    switch (state) {
      case ContractState.PRE_CREATE:
      case ContractState.PENDING:
        statusColor = HexColor('#EED197');
        break;

      case ContractState.ACTIVE:
      case ContractState.DUE:
        statusColor = HexColor('#1FB9C7');
        break;

      case ContractState.CANCELLED:
      case ContractState.CANCELLED_COMPLETED:
      case ContractState.FAIL:
        statusColor = HexColor('#F30202');
        break;

      default:
        statusColor = HexColor('#999999');
        break;
    }
    return statusColor;
  }

  static HexColor statusColor(Map3InfoStatus state) {
    if (state == null) return HexColor('#1FB9C7');

    Color statusColor = HexColor('#EED197');

    switch (state) {
      case Map3InfoStatus.PRE_CREATE:
      case Map3InfoStatus.PENDING:
        statusColor = HexColor('#EED197');
        break;

      case Map3InfoStatus.ACTIVE:
      case Map3InfoStatus.DUE:
        statusColor = HexColor('#1FB9C7');
        break;

      case Map3InfoStatus.CANCELLED:
      case Map3InfoStatus.CANCELLED_COMPLETED:
      case Map3InfoStatus.FAIL:
        statusColor = HexColor('#F30202');
        break;

      default:
        statusColor = HexColor('#999999');
        break;
    }
    return statusColor;
  }

}