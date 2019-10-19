import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/util/validator_util.dart';

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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
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
              TextFormField(
                validator: (value) {
                  if (!ValidatorUtil.validateMoney(value)) {
                    return "请输入正确的金额";
                  } else {
                    return null;
                  }
                },
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
                            if (_formKey.currentState.validate()) {
                              double amount = double.parse(_rechargeCountController.text);
                              Navigator.of(context).pop(amount);
                            }
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
      ),
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
