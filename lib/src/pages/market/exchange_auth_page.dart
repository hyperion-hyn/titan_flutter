import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class ExchangeAuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangeAuthPageState();
  }
}

class _ExchangeAuthPageState extends BaseState<ExchangeAuthPage> {
  bool _isNoWallet = true;

  @override
  Future<void> onCreated() async {
    // TODO: implement onCreated
    super.onCreated();
    _isNoWallet = await _isWalletListEmpty();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isNoWallet ? _noWalletView() : Container(),
    );
  }

  _noWalletView() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 32,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'res/drawable/safe_lock.png',
              width: 100,
              height: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: 300,
              child: Text(
                '你必须先拥有一个私密去中心化钱包，然后授权使用交易兑换功能。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          ClickOvalButton(
            S.of(context).create_wallet,
            () {
              Application.router.navigateTo(
                context,
                Routes.wallet_manager,
              );
            },
            height: 45,
          )
        ],
      ),
    );
  }

  _isWalletListEmpty() async {
//    var wallets = await WalletUtil.scanWallets();
//    return wallets.isEmpty;
    return true;
  }
}
