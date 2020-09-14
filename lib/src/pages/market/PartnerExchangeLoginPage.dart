import 'package:flutter/material.dart';

import '../../widget/loading_button/click_oval_button.dart';
import 'exchange/exchange_page.dart';
import 'exchange_detail/exchange_detail_page.dart';

class PartnerExchangeLoginPage extends StatefulWidget {
  PartnerExchangeLoginPage();

  @override
  State<StatefulWidget> createState() {
    return _PartnerExchangeLoginPageState();
  }
}

class _PartnerExchangeLoginPageState extends State<PartnerExchangeLoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("登录"),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClickOvalButton(
              "登录",
                (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExchangePage()));
                }
            ),
          ),
        ));
  }
}