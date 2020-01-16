import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class RechargeByTitanFinishPage extends StatefulWidget {
  RechargeByTitanFinishPage();

  @override
  State<StatefulWidget> createState() {
    return _RechargeByTitanFinishState();
  }
}

class _RechargeByTitanFinishState extends State<RechargeByTitanFinishPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Image.asset(
                    "res/drawable/check_outline.png",
                    height: 76,
                    width: 124,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    S.of(context).recharge_has_submitted,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S.of(context).please_pay_attention_arrival_of_account,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9B9B9B)),
                  ),
                ),
                SizedBox(
                  height: 36,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                  constraints: BoxConstraints.expand(height: 48),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).confirm,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
