import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/purchase_contract_page.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/utils/utils.dart';

import '../../global.dart';
import 'contract/buy_hash_rate_page_v2.dart';
import 'enter_fund_password.dart';
import 'model/contract_info.dart';
import 'model/contract_info_v2.dart';
import 'model/pay_order.dart';
import 'model/quotes.dart';
import 'my_hash_rate_page.dart';
import 'recharge_purchase_page.dart';
import 'service/user_service.dart';
import 'dart:math';

class PurchasePage extends StatefulWidget {
  final ContractInfoV2 contractInfo;

  final PayOrder payOrder;

  PurchasePage({@required this.contractInfo, @required this.payOrder});

  @override
  State<StatefulWidget> createState() {
    return _PurchaseState();
  }
}

class _PurchaseState extends State<PurchasePage> {
  ///直充余额类型支付
  static const String PAY_BALANCE_TYPE_RECHARGE_HYN = "RB_HYN";
  static const String PAY_BALANCE_TYPE_RECHARGE_USDT = "RB_USDT";
  static const String PAY_BALANCE_TYPE_RECHARGE_HYBRID = "RB_HYBRID";

  ///收益余额类型支付
  static const String PAY_BALANCE_TYPE_INCOME_HYN = "B_HYN";
  String payBalanceType = PAY_BALANCE_TYPE_RECHARGE_USDT;

  // 支付选项
  static const String PAY_OPTION_RECHARGE = "RECHARGE";
  static const String PAY_OPTION_INCOME = "INCOME";
  String payOption = PAY_OPTION_RECHARGE;

  var service = UserService();

//  PayOrder payOrder;
  Quotes quotes;
  UserInfo userInfo;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    //行情
    quotes = await service.quotes();

    //用户余额等信息
    userInfo = await service.getUserInfo();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          S.of(context).power_martgage,
          //"ddd",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)), shape: BoxShape.rectangle),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          S.of(context).product,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          "${widget.contractInfo.name}",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        S.of(context).amount,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(widget.contractInfo.amount)} USDT",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        )),
                  ),
                  _buildHynBalancePayBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  double getBalanceByType(String option, [String chargeType = PAY_BALANCE_TYPE_RECHARGE_HYBRID]) {
    if (userInfo == null) return 0.0;

    //print('balance: ${userInfo.balance}, \ntotalChargeBalance: ${userInfo.totalChargeBalance}, \nchargeHynBalance: ${userInfo.chargeHynBalance}, \nchargeUsdtBalance: ${userInfo.chargeUsdtBalance})');

    double balance = 0;
    if (option == PAY_OPTION_INCOME) {
      balance = (userInfo?.balance ?? 0) - (userInfo?.totalChargeBalance ?? 0);
    } else {
      if (chargeType == PAY_BALANCE_TYPE_RECHARGE_HYN) {
        balance = userInfo?.chargeHynBalance ?? 0;
      } else if (chargeType == PAY_BALANCE_TYPE_RECHARGE_USDT) {
        balance = userInfo?.chargeUsdtBalance ?? 0;
      } else {
        balance = userInfo?.totalChargeBalance ?? 0;
      }
    }

    int decimals = 2;
    int fac = pow(10, decimals);
    //print('fac: $fac');
    double d = balance;
    d = (d * fac).floor() / fac;
    //print("d: $d");

    return d;
  }

  Widget _buildHynBalancePayBox() {
    var hyn = Const.DOUBLE_NUMBER_FORMAT.format(getBalanceByType(PAY_OPTION_RECHARGE, PAY_BALANCE_TYPE_RECHARGE_HYN));
    var usdt = Const.DOUBLE_NUMBER_FORMAT.format(getBalanceByType(PAY_OPTION_RECHARGE, PAY_BALANCE_TYPE_RECHARGE_USDT));
    var input = Const.DOUBLE_NUMBER_FORMAT.format(getBalanceByType(PAY_OPTION_INCOME));

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          //margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        S.of(context).please_mortgage,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '${widget.payOrder?.amount ?? 0}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFCE9D40)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          'USDT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFCE9D40)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Text(S.of(context).by_mortgage),
              ),
              _radioButton(
                  title: S.of(context).becharge_amount,
                  groupValue: payOption,
                  value: PAY_OPTION_RECHARGE,
                  child: Expanded(
                    child: Text(
                      S.of(context).purchase_title_recharge_func(hyn, usdt),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      payOption = PAY_OPTION_RECHARGE;
                      payBalanceType = PAY_BALANCE_TYPE_RECHARGE_USDT;
                    });
                  }),
              if (payOption == PAY_OPTION_RECHARGE)
                Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Column(
                    children: <Widget>[
                      _radioButton(
                          title: S.of(context).purchase_title_recharge_only_usdt,
                          groupValue: payBalanceType,
                          value: PAY_BALANCE_TYPE_RECHARGE_USDT,
                          isVertical: true,
                          child: Text(
                            S.of(context).buy_need_usdt_only_func(
                                Const.DOUBLE_NUMBER_FORMAT.format(widget.payOrder?.amount) ?? '--'),
                            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
                          ),
                          onTap: () {
                            setState(() {
                              payBalanceType = PAY_BALANCE_TYPE_RECHARGE_USDT;
                            });
                          }),
                      _radioButton(
                          title: S.of(context).purchase_title_recharge_only_hyn,
                          groupValue: payBalanceType,
                          value: PAY_BALANCE_TYPE_RECHARGE_HYN,
                          isVertical: true,
                          child: Text(
                            S.of(context).buy_need_hyn_only_func(
                                Const.DOUBLE_NUMBER_FORMAT.format(widget.payOrder?.amount) ?? '--'),
                            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
                          ),
                          onTap: () {
                            setState(() {
                              payBalanceType = PAY_BALANCE_TYPE_RECHARGE_HYN;
                            });
                          }),
                      _radioButton(
                          title: S.of(context).purchase_title_recharge_usdt_hyn,
                          groupValue: payBalanceType,
                          value: PAY_BALANCE_TYPE_RECHARGE_HYBRID,
                          isVertical: true,
                          child: Text(
                            S.of(context).buy_need_hyn_usdt_func(
                                Const.DOUBLE_NUMBER_FORMAT.format(widget.payOrder?.hynUSDTAmount) ?? '--',
                                Const.DOUBLE_NUMBER_FORMAT.format(widget.payOrder?.erc20USDTAmount) ?? '--'),
                            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
                          ),
                          onTap: () {
                            setState(() {
                              payBalanceType = PAY_BALANCE_TYPE_RECHARGE_HYBRID;
                            });
                          }),
                    ],
                  ),
                ),
              _radioButton(
                  title: S.of(context).income_amount,
                  groupValue: payOption,
                  value: PAY_OPTION_INCOME,
                  child: Expanded(
                    child: Text(S.of(context).purchase_title_input_func(input),
                        style: TextStyle(fontSize: 12, color: Color(0xFF9B9B9B))),
                  ),
                  onTap: () {
                    setState(() {
                      payOption = PAY_OPTION_INCOME;
                      payBalanceType = PAY_BALANCE_TYPE_INCOME_HYN;
                    });
                  }),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: RaisedButton(
                    elevation: 1,
                    color: Color(0xFFD6A734),
                    onPressed: () async {
                      if (userInfo != null && widget.payOrder != null) {
                        if (isInsufficientBalance()) {
                          Fluttertoast.showToast(msg: S.of(context).balance_lack);
                        } else {
                          try {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return EnterFundPasswordWidget();
                                }).then((fundToken) async {
                              if (fundToken == null) {
                                return;
                              }

                              // todo: jison_HYN
                              var code = -1;
                              var msg = "";
                              var orderId = widget.payOrder.order_id;

                              if (payOption == PAY_OPTION_RECHARGE &&
                                  payBalanceType == PAY_BALANCE_TYPE_RECHARGE_HYN &&
                                  widget.contractInfo.type != 3) {
                                PayOrder _payOrder = await service.createOrder(contractId: widget.contractInfo.id);
                                orderId = _payOrder.order_id;
                              }
                              print("[puchase] --->type:${widget.contractInfo.type}, payBalanceType:${payBalanceType}");

                              var ret = await service.confirmPayV3(
                                  orderId: orderId, payType: payBalanceType, fundToken: fundToken);
                              code = ret.code;
                              msg = ret.msg;

                              if (code == 0) {
                                //支付成功
                                Fluttertoast.showToast(msg: S.of(context).action_success_hint);
                                if (createWalletPopUtilName != null) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => MyHashRatePage()),
                                      ModalRoute.withName(createWalletPopUtilName));
                                  createWalletPopUtilName = null;
                                }
                                else {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => MyHashRatePage()));
                                }
                              } else {
                                if (code == -1007) {
                                  Fluttertoast.showToast(msg: S.of(context).over_limit_amount_hint);
                                } else if (code == -1004) {
                                  Fluttertoast.showToast(msg: S.of(context).balance_lack);
                                } else {
                                  Fluttertoast.showToast(msg: msg ?? S.of(context).pay_fail_hint);
                                }
                              }
                            });
                          } catch (e) {
                            logger.e(e);
                            Fluttertoast.showToast(msg: S.of(context).transfer_exception_hint);
                          }
                        }
                      } else {
                        Fluttertoast.showToast(msg: S.of(context).data_exception_hint);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      child: SizedBox(
                          height: 40,
                          width: 192,
                          child: Center(
                              child: Text(
                            S.of(context).confirm_mortgage,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ))),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              if (isInsufficientBalance())
                Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        S.of(context).balance_lack,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RechargePurchasePage(),
                                      settings: RouteSettings(name: "/recharge_purchase_page")))
                              .then((value) async {
                            userInfo = await service.getUserInfo();
                            //payBalanceType = PAY_BALANCE_TYPE_RECHARGE;
                            //payBalanceType_recharge = PAY_BALANCE_TYPE_RECHARGE_USDT_100;
                            setState(() {});
                          });
                        },
                        child: Text(
                          S.of(context).click_charge,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _radioButton(
      {String title, String groupValue, String value, Widget child, bool isVertical = false, void Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: isVertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: value,
                      groupValue: groupValue,
                      onChanged: (value) {
                        onTap();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(title),
                    ),
                  ],
                ),
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0, bottom: 0),
                    child: child,
                  ),
              ],
            )
          : Row(
              children: <Widget>[
                Radio(
                  activeColor: Theme.of(context).primaryColor,
                  value: value,
                  groupValue: groupValue,
                  onChanged: (value) {
                    onTap();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(title),
                ),
                if (child != null) child,
              ],
            ),
    );
  }

  bool isInsufficientBalance() {
    var hyn = getBalanceByType(PAY_OPTION_RECHARGE, PAY_BALANCE_TYPE_RECHARGE_HYN);
    var usdt = getBalanceByType(PAY_OPTION_RECHARGE, PAY_BALANCE_TYPE_RECHARGE_USDT);
    var current = getBalanceByType(payOption, payBalanceType);

    /*
    var input = getBalanceByType(PAY_OPTION_INCOME);
    print('[pay] --> '
        '\ninput:${input}, widget.payOrder.amount:${widget.payOrder.amount}'
        '\nhyn:${hyn}, widget.payOrder.hynUSDTAmount:${widget.payOrder.hynUSDTAmount}, '
        '\nusdt:${usdt}, widget.payOrder.erc20USDTAmount:${widget.payOrder.erc20USDTAmount}'
        '\ncurrent:${current}, widget.payOrder.amount:${widget.payOrder.amount}');
    */
    if (current < widget.payOrder.amount ||
        (hyn < widget.payOrder.hynUSDTAmount && usdt < widget.payOrder.erc20USDTAmount)) {
      return true;
    }
    return false;
  }
}
