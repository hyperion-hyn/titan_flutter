import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_wallet_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

import 'map3_node_pronounce_page.dart';

Widget getMap3NodeWaitItem(BuildContext context, ContractNodeItem contractNodeItem) {
  if (contractNodeItem == null) return Container();

  var state = contractNodeItem.stateValue;

//  var isNotFull = int.parse(contractNodeItem.remainDelegation) > 0;
  var isNotFull = true;
  var fullDesc = "";
  var dateDesc = "";
  var isPending = false;
  switch (state) {
    case ContractState.PRE_CREATE:
    case ContractState.PENDING:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.launcherSecondsLeft);
      dateDesc = S.of(context).active + dateDesc;
      fullDesc = !isNotFull ? S.of(context).delegation_amount_full : "";
      isPending = true;
      break;

    case ContractState.ACTIVE:
      dateDesc = S.of(context).left + FormatUtil.timeStringSimple(context, contractNodeItem.completeSecondsLeft);
      dateDesc = S.of(context).expired + dateDesc;
      break;

    case ContractState.DUE:
      dateDesc = S.of(context).contract_had_expired;
      break;

    case ContractState.CANCELLED:
    case ContractState.CANCELLED_COMPLETED:
    case ContractState.FAIL:
      dateDesc = S.of(context).launch_fail;
      break;

    case ContractState.DUE_COMPLETED:
      dateDesc = S.of(context).contract_had_stop;
      break;

    default:
      break;
  }

  var nodeName = "天道酬勤唐唐";
  var nodeAddress = "节点地址 oxfdaf89fdaff ${UiUtil.shortEthAddress(contractNodeItem.owner, limitLength: 6)}";
  var nodeIdPre = "节点号";
  var nodeId = " ${contractNodeItem.contractCode ?? "PB2020"}";
  var feeRatePre = "管理费：";
  var feeRate = contractNodeItem.announcement ?? "10%";
  var descPre = "描   述：";
  var desc = contractNodeItem.announcement ?? "大家快来参与我的节点吧，收益高高，收益真的很高，";
  var remainDelegation = "${FormatUtil.formatNum(int.parse(contractNodeItem.remainDelegation ?? "10000"))}";
  var date = "2020/12/12 12:12";
  var times = "第一期";

  return InkWell(
    onTap: () async {
      var walletList = await WalletUtil.scanWallets();
      if (walletList.length == 0) {
        Application.router.navigateTo(context,
            Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_CREATE}");
      } else {
        var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
        Application.router.navigateTo(
            context, Routes.map3node_join_contract_page + "?entryRouteName=$entryRouteName&contractId=${1}");
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
//            color: HexColor("#000000").withOpacity(0.08),
//            blurRadius: 16.0,
          ),
        ],
      ),
      margin: const EdgeInsets.only(left: 15.0, right: 15, bottom: 9, top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.asset(
                  "res/drawable/map3_node_default_avatar.png",
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 6,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(TextSpan(children: [
                      TextSpan(text: nodeName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      TextSpan(text: "", style: TextStyles.textC333S14bold),
                    ])),
                    Container(
                      height: 4,
                    ),
                    Text(nodeAddress, style: TextStyles.textC9b9b9bS12),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          text: nodeIdPre,
                          style: TextStyle(
                            color: HexColor("#999999"),
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(text: nodeId, style: TextStyle(fontSize: 13, color: HexColor("#333333")))
                          ]),
                    ),
                    Container(
                      height: 4,
                    ),
                    Container(
                      color: HexColor("#1FB9C7").withOpacity(0.08),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(times, style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    feeRatePre,
                    style: TextStyle(fontSize: 10, color: HexColor("#999999")),
                  ),
                  Text(
                    feeRate,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: HexColor("#333333")),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    descPre,
                    style: TextStyle(fontSize: 10, color: HexColor("#999999")),
                  ),
                  Flexible(
                    child: Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: HexColor("#333333")),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Divider(height: 1, color: Color(0x2277869e)),
            ),
            Row(
              children: <Widget>[
                isNotFull
                    ? RichText(
                        text:
                            TextSpan(text: S.of(context).remain, style: TextStyles.textC9b9b9bS12, children: <TextSpan>[
                          TextSpan(text: remainDelegation, style: TextStyles.textC7c5b00S12),
                          TextSpan(text: "HYN", style: TextStyles.textC9b9b9bS12),
                        ]),
                      )
                    : RichText(
                        text: TextSpan(text: fullDesc, style: TextStyles.textC9b9b9bS12, children: <TextSpan>[]),
                      ),
                Spacer(),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                ),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    height: 30,
                    child: FlatButton(
                      color: HexColor("#FF15B2D2"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      onPressed: () {
                        Application.router.navigateTo(
                            context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
                      },
                      child: Text(isPending ? S.of(context).check_join : S.of(context).detail,
                          style: TextStyle(fontSize: 13, color: Colors.white)),
                      //style: TextStyles.textC906b00S13),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Widget managerSpendWidget(BuildContext buildContext, TextEditingController _rateCoinController,
    {Function reduceFunc, Function addFunc}) {
  return Container(
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
                text: "管理费设置",
                style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: "（1%-20%）",
                    style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                  )
                ]),
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  reduceFunc();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    child: Text(
                      "-",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                    ),
                    decoration: BoxDecoration(
                      color: HexColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 34,
                child: RoundBorderTextField(
                  controller: _rateCoinController,
                  keyboardType: TextInputType.number,
                  bgColor: HexColor("#ffffff"),
                  maxLength: 3,
                  validator: (textStr) {
                    if (textStr.length == 0) {
                      return S.of(buildContext).please_input_hyn_count;
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8.0),
                child: Container(
                  child: Text(
                    "%",
                    style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  addFunc();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    height: 22,
                    width: 22,
                    alignment: Alignment.center,
                    child: Text(
                      "+",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333")),
                    ),
                    decoration: BoxDecoration(
                      color: HexColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget getHoldInNum(BuildContext context, ContractNodeItem contractNodeItem, GlobalKey<FormState> formKey,
    TextEditingController textEditingController, String endProfit, String spendManager, bool isJoin,
    {bool isMyself = false, FocusNode focusNode}) {
  double minTotal = 0;
  double remainTotal = 0;

//  List<int> suggestList =
//      contractNodeItem.contract.suggestQuantity.split(",").map((suggest) => int.parse(suggest)).toList();
  List<int> suggestList = [40000, 60000, 80000];
  /*
  if (isJoin) {
    //calculation
    remainTotal = double.parse(contractNodeItem.remainDelegation);
    double tempMinTotal =
        double.parse(contractNodeItem.contract.minTotalDelegation) * contractNodeItem.contract.minDelegationRate;
    if (remainTotal <= 0) {
      minTotal = 0;
      remainTotal = 0;
      contractNodeItem.remainDelegation = "0";
    } else if (tempMinTotal >= remainTotal) {
      minTotal = remainTotal;
    } else {
      minTotal = tempMinTotal;
    }
  } else {
    remainTotal = double.parse(contractNodeItem.contract.minTotalDelegation);
    minTotal =
        double.parse(contractNodeItem.contract.minTotalDelegation) * contractNodeItem.contract.ownerMinDelegationRate;
  }

  var walletName = WalletInheritedModel.of(context).activatedWallet.wallet.keystore.name;
  walletName = UiUtil.shortString(walletName, limitLength: 6);
*/
  var coinVo = WalletInheritedModel.of(context).getCoinVoOfHyn();
  return Container(
    color: Colors.white,
    padding: EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8, right: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child:
                    Text(S.of(context).mortgage_hyn_num, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              Expanded(
                child: Text(S.of(context).mortgage_wallet_balance(FormatUtil.coinBalanceHumanReadFormat(coinVo)),
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 16.0, right: 36, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "HYN",
                      style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      flex: 1,
                      child: RoundBorderTextField(
                        focusNode: focusNode,
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        hint: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(minTotal)),
                        validator: (textStr) {
                          if (textStr.length == 0) {
                            return S.of(context).please_input_hyn_count;
                          } else if (minTotal == 0) {
                            return "抵押已满";
                          } else if (int.parse(textStr) < minTotal) {
                            return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                          } else if (int.parse(textStr) > remainTotal) {
                            return "不能超过剩余份额";
                          } else if (Decimal.parse(textStr) > Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
                            return S.of(context).hyn_balance_no_enough;
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                if (!isJoin && suggestList.length == 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 49.0, bottom: 18),
                    child: Row(
                      children: [0, 0.5, 1, 0.5, 2].map((value) {
                        if (value == 0.5) {
                          return SizedBox(width: 16);
                        }

                        return InkWell(
                          child: Container(
                            color: HexColor("#1FB9C7").withOpacity(0.08),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(suggestList[value].toString(),
                                style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                          ),
                          onTap: () {
                            textEditingController.text = suggestList[value].toString();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 49,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (isJoin)
                            Row(
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                      text: S.of(context).balance_portion_hyn,
                                      style: TextStyle(
                                          fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text: "${FormatUtil.stringFormatNum(contractNodeItem.remainDelegation)}",
                                          style: TextStyle(
                                              fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                                        )
                                      ]),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                    height: 22,
                                    width: 70,
                                    child: FlatButton(
                                      padding: const EdgeInsets.all(0),
                                      color: HexColor("#FFDE64"),
                                      onPressed: () {
                                        textEditingController.text = contractNodeItem.remainDelegation;
//                                        joinEnougnFunction();
                                      },
                                      child: Text(S.of(context).all_bug,
                                          style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                                    )),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ],
    ),
  );
}

typedef NodePublicCallback = void Function({String value});

Widget editInfoItem(
    BuildContext context, int index, String title, String hint, String detail, NodePublicCallback callback,
    {String subtitle = "", bool hasSubtitle = true, TextInputType keyboardType = TextInputType.text}) {
  return Material(
    child: Ink(
      child: InkWell(
        splashColor: Colors.blue,
        onTap: () async {
          if (index == 0) {
            EditIconSheet(context, (path) {
              callback(value: path);
            });
            return;
          }

          String text = await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Map3NodePronouncePage(
                    title: title,
                    hint: hint,
                    text: detail,
                    keyboardType: keyboardType,
                  )));
          if (text?.isNotEmpty ?? false) {
            callback(value: text);
          }
        },
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
            child: Row(
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(color: HexColor("#333333"), fontSize: 16),
                ),
                if (hasSubtitle)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: subtitle.isEmpty
                        ? Text(
                            ' * ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HexColor("#FFFF4C3B"),
                              fontSize: 16,
                            ),
                          )
                        : Text(
                            subtitle,
                            style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                          ),
                  ),
                (index == 0)
                    ? Spacer()
                    : SizedBox(
                        width: 12,
                      ),
                index != 0
                    ? Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            detail.isEmpty ? hint : detail,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: detail.isEmpty ? HexColor("#999999") : HexColor("#333333"), fontSize: 14),
                          ),
                        ),
                      )
                    : detail.isEmpty
                        ? Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: HexColor('#FFDEDEDE'),
                            ),
                            child: Center(
                              child: Text(
                                "+",
                                style: TextStyle(color: Colors.white, fontSize: 26),
                              ),
                            ),
                          )
                        : Image.asset(
                            detail ?? "res/drawable/ic_map3_node_item_2.png",
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right,
                    color: DefaultColors.color999,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget rowTipsItem(String title, {double top = 8, String subTitle = "", GestureTapCallback onTap}) {
  var _nodeWidget = Padding(
    padding: const EdgeInsets.only(right: 10, top: 10),
    child: Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: DefaultColors.color999,
          border: Border.all(color: DefaultColors.color999, width: 1.0)),
    ),
  );

  return Padding(
    padding: EdgeInsets.only(top: top),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _nodeWidget,
        Expanded(
            child: InkWell(
          onTap: onTap,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: subTitle,
                  style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12),
                )
              ],
              text: title,
              style: TextStyle(height: 1.8, color: DefaultColors.color999, fontSize: 12),
            ),
          ),
        )),
      ],
    ),
  );
}

Widget profitListWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(detail, style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
        Container(
          height: 4,
        ),
        Text(title, style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal)),
      ],
    );
  }

  return _profitListWidget(list, horizontal: 30, func: _buildColumn);
}

Widget profitListBigWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(detail, style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
          Container(
            height: 4,
          ),
          Text(title, style: TextStyle(fontSize: 10, color: HexColor("#999999"), fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  return _profitListWidget(list, func: _buildColumn);
}

Widget profitListLightWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(detail, style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
          Container(
            height: 4,
          ),
          Text(title, style: TextStyle(fontSize: 10, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  return _profitListWidget(list, func: _buildColumn);
}

Widget profitListBigLightWidget(List<Map> list) {
  Widget _buildColumn({String title, String detail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(detail, style: TextStyle(fontSize: 18, color: HexColor("#333333"), fontWeight: FontWeight.w600)),
        Container(
          height: 5,
        ),
        Text(title, style: TextStyle(fontSize: 11, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
      ],
    );
  }

  return _profitListWidget(list, horizontal: 30, func: _buildColumn);
}

typedef ProfitBuildFunc = Widget Function({String title, String detail});

Widget _profitListWidget(List<Map> list, {double horizontal = 10, ProfitBuildFunc func}) {
  _buildLine() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Container(
        height: 15,
        width: 0.5,
        color: HexColor("#000000").withOpacity(0.2),
      ),
    );
  }

  List<Widget> children = [];
  for (int index = 0; index < list.length; index++) {
    var map = list[index];
    var title = map.keys.first;
    var detail = map.values.first;
    var column = func(title: title, detail: detail);
    children.add(column);
    if (index != (list.length - 1)) {
      var line = _buildLine();
      children.add(line);
    }
  }

  MainAxisAlignment mainAxisAlignment = list.length == 2 ? MainAxisAlignment.start : MainAxisAlignment.center;
  return Row(
    mainAxisAlignment: mainAxisAlignment,
    children: children,
  );
}
