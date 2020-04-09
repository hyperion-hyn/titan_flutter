import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/me/enter_fund_password.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/config/extends_icon_font.dart';

import 'model/quotes.dart';
import 'model/withdrawal_info.dart';
import 'service/user_service.dart';

class DrawBalancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DrawBalanceState();
  }
}

class _DrawBalanceState extends BaseState<DrawBalancePage> {
  UserService _userService = UserService();
  WithdrawalInfo withdrawalInfo = WithdrawalInfo(0, 0, 0, 0, 0);
  WithdrawalInfo earningWithdrawalInfo;
  WithdrawalInfo rechargeWithdrawalInfo;

  Quotes quotes;

  TextEditingController amountTEController = TextEditingController();
  TextEditingController addressTEController = TextEditingController();

  //手续费
  double fee = 0;

  //到账数量
  double canGetHynAmount = 0;
  double amount = 0;

  static const EARNING = "earning";
  static const RECHARGE = "recharge";

  static const EARNING_INT_TYPE = 0;
  static const RECHARGE_INT_TYPE = 1;

  String _selectedWithdrawalTypeString = EARNING;

  @override
  void initState() {
    super.initState();

    amountTEController.addListener(() {
      setState(() {
        _updateCanGetHynAmount();
      });
    });

    loadData(_selectedWithdrawalTypeString);
  }

  @override
  void onCreated() {
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      _showAlertDialog();
    });
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              S.of(context).withdrawal_tips,
              style: TextStyle(color: Colors.red[700]),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: S.of(context).withdrawal_address,
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: S.of(context).only_accept_hyn_addresses,
                            style: TextStyle(fontSize: 18.0, color: Colors.red, fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: S.of(context).do_not_provide_other_address,
                            style: TextStyle(fontSize: 16.0, color: Colors.black)),
                      ]),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(S.of(context).i_already_know),
              ),
            ],
          );
        });
  }

  void loadData(String _typeString) async {
    try {
      var _withdrawalInfo = await _userService.withdrawalInfo(_typeString);
      var _quotes = await _userService.quotes();

      print('loadData，_typeString: $_typeString, _selectedTypeString: $_selectedWithdrawalTypeString');
      if (_typeString == _selectedWithdrawalTypeString) {
        setState(() {
          _setWithDrawalInfo(_withdrawalInfo, _typeString);
          withdrawalInfo = _withdrawalInfo;
          quotes = _quotes;
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  void _setSelectedWithdrawalTypeString(String _typeString) {
    setState(() {
      _selectedWithdrawalTypeString = _typeString;
      _updateCanGetHynAmount();
      _getWithDrawalInfo();
    });
  }

  void _updateCanGetHynAmount() {
    if (withdrawalInfo != null && quotes != null) {
      double _amount = amountTEController.text.isEmpty ? 0.0 : double.parse(amountTEController.text);
      print('amount is: $_amount');

      amount = _amount;
      fee = withdrawalInfo.free_rate * amount;
      //if (_selectedWithdrawalTypeString == RECHARGE) fee = 0;
      canGetHynAmount = (amount - fee) / quotes.rate;
      print('canGetHynAmount is: $canGetHynAmount');
    }
  }

  void _setWithDrawalInfo(WithdrawalInfo _withdrawalInfo, String _typeString) {
    if (_typeString == EARNING) {
      earningWithdrawalInfo = _withdrawalInfo;
    } else if (_typeString == RECHARGE) {
      rechargeWithdrawalInfo = _withdrawalInfo;
    }
  }

  void _getWithDrawalInfo() {
    WithdrawalInfo _withdrawalInfo;
    if (_selectedWithdrawalTypeString == EARNING) {
      _withdrawalInfo = earningWithdrawalInfo;
    } else if (_selectedWithdrawalTypeString == RECHARGE) {
      _withdrawalInfo = rechargeWithdrawalInfo;
    }

    if (_withdrawalInfo != null) {
      withdrawalInfo = _withdrawalInfo;
    } else {
      loadData(_selectedWithdrawalTypeString);
    }

    print('_selectedWithdrawalTypeString is: $_selectedWithdrawalTypeString, withdrawalInfo is: $_withdrawalInfo');
  }

  @override
  Widget build(BuildContext context) {
    var balance = '--';
    if (withdrawalInfo?.balance != null) {
      balance = Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo?.balance);
    }
    var maxWithdrawal = '--';
    if (withdrawalInfo?.can_withdrawal != null) {
      maxWithdrawal = Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo?.can_withdrawal);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).withdrawal,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RadioListTile(
                              activeColor: Theme.of(context).primaryColor,
                              groupValue: _selectedWithdrawalTypeString,
                              title: Text(S.of(context).earnings_balance),
                              value: EARNING,
                              onChanged: (value) {
                                _setSelectedWithdrawalTypeString(value);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              activeColor: Theme.of(context).primaryColor,
                              groupValue: _selectedWithdrawalTypeString,
                              title: Text(S.of(context).recharge_balance),
                              value: RECHARGE,
                              onChanged: (value) {
                                _setSelectedWithdrawalTypeString(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "$balance USDT",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).primaryColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.info,
                              size: 12,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                S.of(context).max_withdrawal_quantity(maxWithdrawal),
                                style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          S.of(context).hyn_withdrawal_coin_address,
                          style: TextStyle(color: Color(0xFF6D6D6D)),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () async {
                            getAddressTitanWallet();
                          },
                          child: Text(
                            S.of(context).my_wallet_address,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: addressTEController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), gapPadding: 4),
                              contentPadding: EdgeInsets.all(16),
                              hintStyle: TextStyle(fontSize: 14),
                              hintText: S.of(context).please_input_hyn_address,
                              suffixIcon: Container(
                                margin: const EdgeInsets.only(left: 16, right: 8),
                                child: InkWell(
                                  onTap: () async {
                                    String barcode = await BarcodeScanner.scan();
                                    /*if (barcode.indexOf(':') > 0) {
                                      var ls = barcode.split(':');
                                      barcode = ls[ls.length - 1];
                                    }*/

                                    //print('[barcode] --->1, barcode:${barcode}, length:${barcode.length}');

                                    if (barcode.length > 42) {
                                      // 1.针对本APP"充值"生成的地址判断
                                      if (barcode.startsWith("ethereum:")) {
                                        var ls = barcode.split('ethereum:');
                                        barcode = ls[ls.length - 1];
                                      }
                                    }

                                    // 1.针对IM-TokenAPP"充值"生成的地址判断
                                    if (barcode.startsWith("0x")) {
                                      barcode = barcode.substring(0, 42);
                                    }

                                    //print('[barcode] --->2, barcode:${barcode}, length:${barcode.length}');

                                    if (barcode.length == 42) {
                                      addressTEController.text = barcode;
                                    } else {
                                      Fluttertoast.showToast(msg: S.of(context).no_eth_address);
                                    }
                                  },
                                  child: Icon(
                                    ExtendsIconFont.qrcode_scan,
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      S.of(context).quantity,
                      style: TextStyle(color: Color(0xFF6D6D6D)),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          maxLength: 20,
                          keyboardType: TextInputType.number,
                          controller: amountTEController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                gapPadding: 4,
                              ),
                              contentPadding: EdgeInsets.all(16),
                              hintStyle: TextStyle(fontSize: 14),
                              hintText: S.of(context).please_input_withdrawal_quantity,
                              suffixIcon: Container(
                                margin: const EdgeInsets.only(left: 16, right: 8, top: 20),
                                child: Text(
                                  "USDT",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9B9B9B)),
                                ),
                              )),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Divider(),
                        Text(
                          S
                              .of(context)
                              .withdrawal_fee(Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo.free_rate * 100)),
                          style: TextStyle(color: Colors.black54),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("${Const.DOUBLE_NUMBER_FORMAT.format(fee)} USDT"),
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Text(
                              S.of(context).amount_received,
                              style: TextStyle(color: Colors.black54),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  S.of(context).actual_amount_received,
                                  style: TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("≈${Const.DOUBLE_NUMBER_FORMAT.format(canGetHynAmount)} HYN"),
                        ),
                        Divider(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.info_outline, color: Color(0xFFCE9D40)),
                  ),
                  Expanded(
                    child: Text(
                      S.of(context).withdrawal_audit_message,
                      style: TextStyle(color: Color(0xFFCE9D40), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: SizedBox(
                      height: 42,
                      child: RaisedButton(
                        onPressed: () async {
                          if (withdrawalInfo != null) {
                            var address = addressTEController.text.trim();
                            if (amount > withdrawalInfo.can_withdrawal) {
                              Fluttertoast.showToast(msg: S.of(context).over_max_withdrawal);
                            } else if (amount < withdrawalInfo.min_limit) {
                              Fluttertoast.showToast(msg: S.of(context).below_min_withdrawal);
                            } else if (address.isEmpty) {
                              Fluttertoast.showToast(msg: S.of(context).please_input_hyn_withdrawal_address);
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
                                  int type;
                                  if (_selectedWithdrawalTypeString == EARNING) {
                                    type = EARNING_INT_TYPE;
                                  } else if (_selectedWithdrawalTypeString == RECHARGE) {
                                    type = RECHARGE_INT_TYPE;
                                  }
                                  print('[提币】 --> Action...');

                                  await _userService.withdrawalApplyV2(
                                      amount: amount, address: address, fundToken: fundToken, type: type);
                                  Fluttertoast.showToast(msg: S.of(context).withdrawal_apply_success);
                                  Navigator.pop(context, true);
                                  print('[提币】 --> 成功');
                                });
                              } catch (e) {
                                logger.e(e);
                                Fluttertoast.showToast(msg: S.of(context).withdrawal_fail);
                              }
                            }
                          }
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          S.of(context).withdrawal,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future getAddressTitanWallet() async {
    WalletVo _walletVo = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).activatedWallet;
    if (_walletVo == null) {
      showDialog(
          context: context,
          builder: (context) {
            return Platform.isIOS
                ? CupertinoAlertDialog(
                    title: Text(S.of(context).tips),
                    content: Text(S.of(context).without_hyn_wallet),
                    actions: <Widget>[
//                      new FlatButton(
//                        onPressed: () {
////                          createWalletPopUtilName = "/draw_balance_page";
//                          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
//                        },
//                        child: new Text(S.of(context).create),
//                      ),
//                      new FlatButton(
//                        onPressed: () {
////                          createWalletPopUtilName = "/draw_balance_page";
//                          Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
//                        },
//                        child: new Text(S.of(context).import),
//                      ),
                      new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: new Text(S.of(context).close),
                      ),
                    ],
                  )
                : AlertDialog(
                    title: new Text(S.of(context).tips),
                    content: new Text(S.of(context).without_hyn_wallet),
                    actions: <Widget>[
//                      new FlatButton(
//                        onPressed: () {
////                          createWalletPopUtilName = "/draw_balance_page";
//                          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
//                        },
//                        child: new Text(S.of(context).create),
//                      ),
//                      new FlatButton(
//                        onPressed: () {
////                          createWalletPopUtilName = "/draw_balance_page";
//                          Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
//                        },
//                        child: new Text(S.of(context).import),
//                      ),
                      new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: new Text(S.of(context).close),
                      ),
                    ],
                  );
          });
    } else {
      var address = _walletVo.wallet.getEthAccount().address;
      addressTEController.text = address;
    }
  }
}
