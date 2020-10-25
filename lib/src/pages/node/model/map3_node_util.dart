
import 'dart:ui';

import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
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

  /*
  MAP,
  CREATE_SUBMIT_ING,
  CREATE_FAIL,
  FUNDRAISING_NO_CANCEL,
  FUNDRAISING_CANCEL_SUBMIT,
  CANCEL_NODE_SUCCESS,
  CONTRACT_HAS_STARTED,
  CONTRACT_IS_END,
  */
  static HexColor statusColor(Map3InfoStatus state) {
    if (state == null) return HexColor('#1FB9C7');

    var _map3StatusColor = HexColor("#1FB9C7");
    switch (state) {
      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
      case Map3InfoStatus.CONTRACT_HAS_STARTED:
      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
        _map3StatusColor = HexColor("#1FB9C7");
        break;

      case Map3InfoStatus.CREATE_FAIL:
      case Map3InfoStatus.CONTRACT_IS_END:
      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        _map3StatusColor = HexColor("#FF4C3B");
        break;

      default:
        _map3StatusColor = HexColor("#1FB9C7");
        break;
    }

    return _map3StatusColor;
  }

  static HexColor statusBorderColor(Map3InfoStatus state) {
    if (state == null) return HexColor('#CBF6FF');

    var _map3StatusColor = HexColor("#CBF6FF");
    switch (state) {
      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
      case Map3InfoStatus.CONTRACT_HAS_STARTED:
      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
        _map3StatusColor = HexColor("#CBF6FF");
        break;

      case Map3InfoStatus.CREATE_FAIL:
      case Map3InfoStatus.CONTRACT_IS_END:
      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        _map3StatusColor = HexColor("#FFC8C3");
        break;

      default:
        _map3StatusColor = HexColor("#CBF6FF");
        break;
    }

    return _map3StatusColor;
  }
}