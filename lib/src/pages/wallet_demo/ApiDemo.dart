import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/api/exchange_const.dart';
import 'package:titan/src/pages/wallet_demo/recaptcha_test_page.dart';
import 'package:titan/src/utils/utile_ui.dart';

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
              var verifyCode = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecaptchaTestPage(
                            language: 'zh-CN',
                            apiKey: '6LeIXagZAAAAAKXVvQRHPTvmO4XLoxoeBtOjE5xH',
                          )));
              if (verifyCode != null) {
                UiUtil.toast('获得google人机验证码 $verifyCode');
              }
            },
            child: Text('人机验证'),
          ),
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
                var walletPassword = await UiUtil.showWalletPasswordDialogV2(
                    context, wallet.wallet);

                var ret = await _exchangeApi.walletSignLogin(
                  wallet: wallet.wallet,
                  password: walletPassword,
                  address: address,
                );

                print(ret);
              }
            },
            child: Text('使用钱包注册账户'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.getAssetsList();
              print(ret);
            },
            child: Text('查看用户资产'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.testRecharge('HYN', 10000);
              print(ret);
            },
            child: Text('充10000HYN'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.testRecharge('USDT', 1000);
              print(ret);
            },
            child: Text('充1000USDT'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.testRecharge('ETH', 1000);
              print(ret);
            },
            child: Text('充1000ETH'),
          ),
        ],
      ),
    );
  }
}
