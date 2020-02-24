import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/business/me/model/experience_info_v2.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/style/titan_sytle.dart';

import '../../global.dart';
import 'enter_fund_password.dart';
import 'model/contract_info_v2.dart';
import 'model/pay_order.dart';
import 'my_hash_rate_page.dart';
import 'recharge_purchase_page.dart';
import 'service/user_service.dart';
import 'dart:math';

class PurchaseContractPage extends StatefulWidget {
  final ContractInfoV2 contractInfo;

  PurchaseContractPage({@required this.contractInfo});

  @override
  State<StatefulWidget> createState() {
    return _PurchaseContractState();
  }
}

class _PurchaseContractState extends State<PurchaseContractPage> {
  int payType = 1; //0: HYN 1：HYN余额

  ///直充余额类型支付
  static const String PAY_BALANCE_TYPE_RECHARGE = "RB_HYN";

  String payBalanceType = PAY_BALANCE_TYPE_RECHARGE;

  var service = UserService();

  UserInfo userInfo;
  ExperienceInfoV2 experienceInfo = ExperienceInfoV2(0, 0);
  PayOrder payOrder;

  TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _descController.dispose();
  }

  void loadData() async {
    //用户余额等信息
    userInfo = await service.getUserInfo();

    //体验信息
    experienceInfo = await service.experience(widget.contractInfo.id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          S.of(context).experience_contract_mortgage,
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
                children: <Widget>[],
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
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          )),
                      child: Row(
                        children: <Widget>[
                          Text(S.of(context).select_contract_quantity),
                          Spacer(),
                        ],
                      )),
                  _buildHynBalancePayBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  double getBalanceByType(String type, [String chargeType = 'hyn']) {
    if (userInfo == null) return 0.0;

    //print('balance: ${userInfo.balance}, chargeBalance: ${userInfo.chargeBalance})');

    double balance = 0;
    if (chargeType == 'hyn') {
      balance = userInfo?.chargeHynBalance ?? 0;
    } else if (chargeType == 'usdt') {
      balance = userInfo?.chargeUsdtBalance ?? 0;
    } else {
      balance = userInfo?.totalChargeBalance ?? 0;
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
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildInputCell(),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: RaisedButton(
                  elevation: 1,
                  color: Color(0xFFD6A734),
                  onPressed: () async {
                    var countText = _descController.text;
                    if (countText.isEmpty) {
                      Fluttertoast.showToast(
                          msg: S.of(context).experience_numbers_not_empty, gravity: ToastGravity.CENTER);
                      return;
                    }

                    try {
                      payOrder = await service.createExperienceOrder(
                          contractId: widget.contractInfo.id, count: int.parse(countText));
                    } catch (e) {
                      logger.e(e);
                      if (e is HttpResponseCodeNotSuccess) {
                        if (e.code == -1007) {
                          Fluttertoast.showToast(msg: S.of(context).over_limit_amount_hint);
                        } else if (e.code == -1004) {
                          Fluttertoast.showToast(msg: S.of(context).balance_lack);
                        } else {
                          Fluttertoast.showToast(msg: e.message ?? S.of(context).pay_fail_hint);
                        }
                        return ;
                      }
                    }

                    if (userInfo != null && payOrder != null) {
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
                            var ret = await service.confirmExperiencePay(
                                orderId: payOrder.order_id, payType: payBalanceType, fundToken: fundToken);
                            if (ret.code == 0) {
                              //支付成功
                              Fluttertoast.showToast(msg: S.of(context).action_success_hint);
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                            } else {
                              if (ret.code == -1007) {
                                Fluttertoast.showToast(msg: S.of(context).over_limit_amount_hint);
                              } else if (ret.code == -1004) {
                                Fluttertoast.showToast(msg: S.of(context).balance_lack);
                              } else {
                                Fluttertoast.showToast(msg: ret.msg ?? S.of(context).pay_fail_hint);
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
                            payBalanceType = PAY_BALANCE_TYPE_RECHARGE;
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

  Widget _buildInputCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 10),
          child: Text(
            S.of(context).input_contract_quantity,
            style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 45, top: 6, bottom: 10),
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
            child: TextFormField(
              controller: _descController,
              validator: (value) {
                if (value == null || value.trim().length == 0) {
                  return S.of(context).experience_numbers_not_empty;
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.number,
              maxLength: null,
              maxLines: null,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).experience_upper_func(experienceInfo.canBuy.toString()),
                hintStyle: TextStyle(fontSize: 14, color: DefaultColors.color777),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 10),
          child: Text(
            S
                .of(context)
                .experience_avaliable_func(Const.DOUBLE_NUMBER_FORMAT.format(getBalanceByType(payBalanceType))),
            //S.of(context).available_balance_usdt(Const.DOUBLE_NUMBER_FORMAT.format(getBalanceByType(payBalanceType))),
            style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
          ),
        ),
      ],
    );
  }

  bool isInsufficientBalance() {
    var count = 0;
    if (_descController.text.isNotEmpty) {
      count = int.parse(_descController.text);
    }
    if (getBalanceByType(payBalanceType, 'total') < count * 10) {
      return true;
    }
    return false;
  }
}
