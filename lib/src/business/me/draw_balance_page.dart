import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/enter_fund_password.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

import 'model/quotes.dart';
import 'model/withdrawal_info.dart';
import 'service/user_service.dart';

class DrawBalancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DrawBalanceState();
  }
}

class _DrawBalanceState extends State<DrawBalancePage> {
  UserService _userService = UserService();
  WithdrawalInfo withdrawalInfo = WithdrawalInfo(0, 0, 0, 0, 0);
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
      if (withdrawalInfo != null && quotes != null) {
        double _amount = amountTEController.text.isEmpty ? 0.0 : double.parse(amountTEController.text);
//        if (_amount > withdrawalInfo.can_withdrawal) {
//          _amount = withdrawalInfo.can_withdrawal;
//          amountTEController.text = '$_amount';
//          amountTEController.selection = TextSelection.collapsed(offset: amountTEController.text.length - 1);
//        }
        /*else if(_amount < withdrawalInfo.min_limit) {
          _amount = withdrawalInfo.min_limit;
          amountTEController.text = '$_amount';
          amountTEController.selection = TextSelection.collapsed(offset: amountTEController.text.length - 1);
        }*/
        print('amount is: $_amount');
        setState(() {
          amount = _amount;
          fee = withdrawalInfo.free_rate * amount;
          canGetHynAmount = (amount - fee) / quotes.avgRate;
        });
      }
    });

    loadData();
  }

  void loadData() async {
    try {
      var _withdrawalInfo = await _userService.withdrawalInfo(_selectedWithdrawalTypeString);
      var _quotes = await _userService.quotes();
      setState(() {
        withdrawalInfo = _withdrawalInfo;
        quotes = _quotes;
      });
    } catch (e) {
      logger.e(e);
    }
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

    if (_selectedWithdrawalTypeString == EARNING) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
//        backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "提币",
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
                                title: Text("收益余额"),
                                value: EARNING,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWithdrawalTypeString = value;
                                    loadData();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                activeColor: Theme.of(context).primaryColor,
                                groupValue: _selectedWithdrawalTypeString,
                                title: Text("充值余额"),
                                value: RECHARGE,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWithdrawalTypeString = value;
                                    loadData();
                                  });
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
                                  '最多可提 $maxWithdrawal USDT',
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
                      child: Text(
                        "HYN提币地址",
                        style: TextStyle(color: Color(0xFF6D6D6D)),
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
                                hintText: "请输入HYN地址",
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(left: 16, right: 8),
                                  child: InkWell(
                                    onTap: () async {
                                      String barcode = await BarcodeScanner.scan();
                                      if (barcode.indexOf(':') > 0) {
                                        var ls = barcode.split(':');
                                        barcode = ls[ls.length - 1];
                                      }
                                      print('xxxxx $barcode');
                                      print(barcode);
                                      if (barcode.length != 40 && barcode.length != 42) {
                                        Fluttertoast.showToast(msg: "非以太坊地址");
                                      } else {
                                        addressTEController.text = barcode;
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
                        "数量",
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
                                hintText: "请输入提币数量",
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
                            "手续费(${Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo.free_rate*100)}%)",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("${Const.DOUBLE_NUMBER_FORMAT.format(fee)} USDT"),
                          ),
                          Divider(),
                          Text(
                            "到账数量",
                            style: TextStyle(color: Colors.black54),
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
                        "将换算成相应的HYN到你的提币地址上。为保障资金安全，我们会对提币进行人工审核，请耐心等待工作人员电话或邮件联系。",
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
                                Fluttertoast.showToast(msg: "超出最大提币额度");
                              } else if (amount < withdrawalInfo.min_limit) {
                                Fluttertoast.showToast(msg: "低于最小提币额度");
                              } else if (address.isEmpty) {
                                Fluttertoast.showToast(msg: "请输入HYN提币地址");
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
                                    await _userService.withdrawalApply(
                                        amount: amount, address: address, fundToken: fundToken, type: type);
                                    Fluttertoast.showToast(msg: "提币申请成功");
                                    Navigator.pop(context, true);
                                  });
                                } catch (e) {
                                  logger.e(e);
                                  Fluttertoast.showToast(msg: "提币出错");
                                }
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            "提币",
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
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
//        backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "提币",
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
                                title: Text("收益余额"),
                                value: EARNING,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWithdrawalTypeString = value;
                                    loadData();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                activeColor: Theme.of(context).primaryColor,
                                groupValue: _selectedWithdrawalTypeString,
                                title: Text("充值余额"),
                                value: RECHARGE,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWithdrawalTypeString = value;
                                    loadData();
                                  });
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
                                  '最多可提 $maxWithdrawal USDT',
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
                      child: Text(
                        "HYN提币地址",
                        style: TextStyle(color: Color(0xFF6D6D6D)),
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
                                hintText: "请输入HYN地址",
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(left: 16, right: 8),
                                  child: InkWell(
                                    onTap: () async {
                                      String barcode = await BarcodeScanner.scan();
                                      if (barcode.indexOf(':') > 0) {
                                        var ls = barcode.split(':');
                                        barcode = ls[ls.length - 1];
                                      }
                                      print('xxxxx $barcode');
                                      print(barcode);
                                      if (barcode.length != 40 && barcode.length != 42) {
                                        Fluttertoast.showToast(msg: "非以太坊地址");
                                      } else {
                                        addressTEController.text = barcode;
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
                        "数量",
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
                                hintText: "请输入提币数量",
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
//                          Text(
//                            "手续费(${Const.DOUBLE_NUMBER_FORMAT.format(withdrawalInfo.free_rate*100)}%)",
//                            style: TextStyle(color: Colors.black54),
//                          ),
//                          Padding(
//                            padding: const EdgeInsets.symmetric(vertical: 8.0),
//                            child: Text("${Const.DOUBLE_NUMBER_FORMAT.format(fee)} USDT"),
//                          ),
//                          Divider(),
                          Text(
                            "到账数量",
                            style: TextStyle(color: Colors.black54),
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
                        "将换算成相应的HYN到你的提币地址上。为保障资金安全，我们会对提币进行人工审核，请耐心等待工作人员电话或邮件联系。",
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
                                Fluttertoast.showToast(msg: "超出最大提币额度");
                              } else if (amount < withdrawalInfo.min_limit) {
                                Fluttertoast.showToast(msg: "低于最小提币额度");
                              } else if (address.isEmpty) {
                                Fluttertoast.showToast(msg: "请输入HYN提币地址");
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
                                    await _userService.withdrawalApply(
                                        amount: amount, address: address, fundToken: fundToken, type: type);
                                    Fluttertoast.showToast(msg: "提币申请成功");
                                    Navigator.pop(context, true);
                                  });
                                } catch (e) {
                                  logger.e(e);
                                  Fluttertoast.showToast(msg: "提币出错");
                                }
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            "提币",
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
  }
}
