import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/api/exchange_api.dart';

class ApiDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ApiDemoState();
  }
}

class _ApiDemoState extends State {
  ExchangeApi _exchangeApi = ExchangeApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('api测试'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        children: <Widget>[
          RaisedButton(
            onPressed: () async {
              var wallet = WalletInheritedModel.of(context).activatedWallet;
              if (wallet != null) {
                var address = wallet.wallet.getEthAccount().address;
                var walletPassword = '111111';

                var email = 'moyaying@163.com';
                //1、 获取验证码， 并返回一个token
                dynamic ret = await _exchangeApi.sendSms(email: email);
                print(ret);
              }
            },
            child: Text('获取注册邮件验证码'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallet = WalletInheritedModel.of(context).activatedWallet;
              if (wallet != null) {
                var address = wallet.wallet.getEthAccount().address;
                var walletPassword = '111111';

                var email = 'moyaying@163.com';
                var code = '128181'; //验证码，需要从邮件查看
                var token = '007a84e1f4c4e99380ad51466a1af540'; //从 sendSms 请求那里返回

                var ret = await _exchangeApi.walletSignLogin(
                  wallet: wallet.wallet,
                  password: walletPassword,
                  address: address,
                  email: email,
                  code: code,
                  token: token,
                );

                print(ret);
              }
            },
            child: Text('使用钱包注册账户'),
          )
        ],
      ),
    );
  }
}
