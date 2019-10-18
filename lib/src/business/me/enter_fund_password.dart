import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/me/util/validator_util.dart';

class EnterFundPasswordWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EnterFundPasswordState();
  }
}

class EnterFundPasswordState extends State<EnterFundPasswordWidget> {
  int _countdownTime = 0;
  Timer _timer;

  String email;

  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              children: <Widget>[
                Text(
                  "安全验证",
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
              "资金密码",
              style: TextStyle(color: HexColor("#093956"), fontWeight: FontWeight.bold),
            ),
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(hintText: "请输入资金密码"),
          ),
//          Padding(
//            padding: const EdgeInsets.symmetric(vertical: 16.0),
//            child: Text(
//              "邮箱验证码",
//              style: TextStyle(color: HexColor("#093956"), fontWeight: FontWeight.bold),
//            ),
//          ),
//          TextField(
//            decoration: InputDecoration(
//                hintText: "验证码",
//                suffixIcon: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: FlatButton(
//                      padding: EdgeInsets.all(8),
//                      textColor: Colors.white,
//                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                      onPressed: () {
//                        print("onPressed");
//                        if (_countdownTime == 0) {
//                          _userService.verification(email);
//                          setState(() {
//                            _countdownTime = 60;
//                          });
//                          //开始倒计时
//                          startCountdownTimer();
//                        }
//                      },
//                      color: Theme.of(context).primaryColor,
//                      child: Text(
//                        _countdownTime > 0 ? '$_countdownTime秒后重新获取' : '获取验证码',
//                      )),
//                )),
//            keyboardType: TextInputType.number,
//          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SizedBox(
                    height: 42,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
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
        ]));
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
