import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/recharge_purchase_page.dart';
import 'package:titan/src/business/me/service/user_service.dart';

class EnterRechargeCount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EnterRechargeCountState();
  }
}

class _EnterRechargeCountState extends State<EnterRechargeCount> {
  int _countdownTime = 0;
  Timer _timer;
  String email;

  TextEditingController _rechargeCountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
          child:
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    "充值",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(padding: EdgeInsets.all(4), child: Text("取消")))
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "充值金额",
                style: TextStyle(color: HexColor("#093956"), fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: _rechargeCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "请输入充值金额",
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
                        onPressed: () {
                          Navigator.of(context).pop();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RechargePurchasePage(
                                      rechargeAmount: double.parse(_rechargeCountController.text))));
                        },
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          "确认",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ])),
    );
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _timer.cancel();
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}
