import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
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
  WithdrawalInfo withdrawalInfo;
  Quotes quotes;

  TextEditingController amountTEController = TextEditingController();
  TextEditingController addressTEController = TextEditingController();

  //手续费
  double fee = 0;

  //到账数量
  double canGetHynAmount = 0;

  double amount = 0;

  @override
  void initState() {
    super.initState();

    amountTEController.addListener(() {
      if (withdrawalInfo != null && quotes != null) {
        double _amount = amountTEController.text.isEmpty ? 0.0 : double.parse(amountTEController.text);
        if (_amount > withdrawalInfo.can_withdrawal) {
          _amount = withdrawalInfo.can_withdrawal;
          amountTEController.text = '$_amount';
          amountTEController.selection = TextSelection.collapsed(offset: amountTEController.text.length - 1);
        }
        /*else if(_amount < withdrawalInfo.min_limit) {
          _amount = withdrawalInfo.min_limit;
          amountTEController.text = '$_amount';
          amountTEController.selection = TextSelection.collapsed(offset: amountTEController.text.length - 1);
        }*/
        print('amount is: $_amount');
        setState(() {
          amount = _amount;
          fee = withdrawalInfo.free_rate * amount;
          canGetHynAmount = (amount - fee) / quotes.rate;
        });
      }
    });

    loadData();
  }

  void loadData() async {
    try {
      var _withdrawalInfo = await _userService.withdrawalInfo();
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

    return Scaffold(
      appBar: AppBar(
        title: Text("提币"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 32, bottom: 24),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "余额",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Text(
                    "$balance U",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.info,
                          size: 16,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '最多可提 $maxWithdrawal U',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "HYN提币地址",
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: addressTEController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(6),
                            hintStyle: TextStyle(fontSize: 14),
                            hintText: "请输入HYN地址",
                          ),
                        ),
                      ),
                      Container(
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
                          child: Icon(ExtendsIconFont.qrcode_scan),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "数量",
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
                            contentPadding: EdgeInsets.all(6),
                            hintStyle: TextStyle(fontSize: 14),
                            hintText: "最小提币数量${withdrawalInfo?.min_limit}",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Text("U"),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: FractionColumnWidth(.2),
                  1: FractionColumnWidth(.8),
                },
                children: [
                  TableRow(children: [
                    Text(
                      "手续费",
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text("${Const.DOUBLE_NUMBER_FORMAT.format(fee)} U")
                  ]),
                  TableRow(children: [
                    Text(
                      "到账数量",
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text("≈${Const.DOUBLE_NUMBER_FORMAT.format(canGetHynAmount)} HYN")
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: HexColor("#FFf5f4fa"),
                    shape: BoxShape.rectangle),
                child: Text(
                  "将换算成相应的HYN到你的提币地址上。为保障资金安全，我们会对提币进行人工审核，请耐心等待工作人员电话或邮件联系。",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
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
                                    context: context,
                                    builder: (BuildContext context) {
                                      return EnterFundPasswordWidget();
                                    }).then((value) async {
                                  await _userService.withdrawalApply(amount: amount, address: address);
                                  Fluttertoast.showToast(msg: "提币申请成功");
                                  Navigator.pop(context, true);
                                });
                              } catch (e) {
                                logger.e(e);
                                Fluttertoast.showToast(msg: "提币出错");
                              }
                            }
                          }

//
                        },
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
