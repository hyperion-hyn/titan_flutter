import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/exchange/bloc/bloc.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class ExchangeAuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangeAuthPageState();
  }
}

class _ExchangeAuthPageState extends BaseState<ExchangeAuthPage> {
  bool isLoggingIn = false;

  @override
  Future<void> onCreated() async {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(WalletInheritedModel.of(context).activatedWallet);
    return BlocListener<ExchangeCmpBloc, ExchangeCmpState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          setState(() {
            isLoggingIn = false;
          });
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: '登录成功');
        } else if (state is LoginFailState) {
          setState(() {
            isLoggingIn = false;
          });
          Fluttertoast.showToast(msg: '登录失败');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: debugInstrumentationEnabled,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            '授权',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        body: WalletInheritedModel.of(context).activatedWallet == null
            ? _noWalletView()
            : _authorizeView(),
      ),
    );
  }

  _authorizeView() {
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
          Container(
            width: 200,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              disabledColor: Colors.grey[600],
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              disabledTextColor: Colors.white,
              onPressed: isLoggingIn
                  ? null
                  : () {
                      _startLogin();
                    },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      isLoggingIn ? '登录中' : '使用钱包授权登录',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _startLogin() async {
    var wallet = WalletInheritedModel.of(context).activatedWallet;
    if (wallet != null) {
      var address = wallet.wallet.getEthAccount().address;
      var walletPassword =
          await UiUtil.showWalletPasswordDialogV2(context, wallet.wallet);
      if (walletPassword != null) {
        BlocProvider.of<ExchangeCmpBloc>(context)
            .add(LoginEvent(wallet.wallet, walletPassword, address));
        setState(() {
          isLoggingIn = true;
        });
      }
    }
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
              ///
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
}
