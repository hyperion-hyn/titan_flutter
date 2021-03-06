import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/pages/policy/policy_util.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

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
    super.onCreated();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      ///
      _checkIsAuthAlready();
    });
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
          _setAuthByBioAuth();
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: S.of(context).exchange_login_success);
        } else if (state is LoginFailState) {
          setState(() {
            isLoggingIn = false;
          });
          Fluttertoast.showToast(msg: S.of(context).exchange_login_failed);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            S.of(context).exchange_auth,
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
          SizedBox(height: 32),
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
                S.of(context).exchange_auth_description(
                      WalletInheritedModel.of(context)?.activatedWallet?.wallet?.keystore?.name,
                    ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
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
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      isLoggingIn
                          ? S.of(context).exchange_loggin_in
                          : S.of(context).exchange_auth_by_wallet,
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

  _checkIsAuthAlready() async {
    var _wallet = WalletInheritedModel.of(context)?.activatedWallet?.wallet;
    if (_wallet != null) {
      bool _isAuthAlready =
          await AppCache.getValue('exchange_auth_already_${_wallet.getEthAccount().address}') ??
              false;
      var _bioAuthEnabled = await BioAuthUtil.bioAuthEnabledByWallet(_wallet, AuthType.exchange);
      if (_isAuthAlready && _bioAuthEnabled) {
        _startLogin();
      }
    }
  }

  _setAuthByBioAuth() {
    var _wallet = WalletInheritedModel.of(context)?.activatedWallet?.wallet;
    AppCache.saveValue(
      'exchange_auth_already_${_wallet.getEthAccount().address}',
      true,
    );
  }

  _startLogin() async {
    var _wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
    if (_wallet != null) {
      if (await PolicyUtil.checkConfirmWalletPolicy()) {
        bool result = await UiUtil.showConfirmPolicyDialog(context, PolicyType.WALLET);
        if (!result) return;
      }

      var address = _wallet.getEthAccount().address;
      var walletPassword = await UiUtil.showWalletPasswordDialogV2(
        context,
        _wallet,
        authType: AuthType.exchange,
      );
      if (walletPassword != null) {
        BlocProvider.of<ExchangeCmpBloc>(context).add(LoginEvent(
          _wallet,
          walletPassword,
          address,
        ));
        setState(() {
          isLoggingIn = true;
        });
      }
    } else {
      Fluttertoast.showToast(msg: 'Wallet is null');
    }
  }

  _noWalletView() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 32),
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
                S.of(context).exchange_auth_no_wallet,
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          ClickOvalButton(
            S.of(context).create_wallet,
            () {
              WalletManagerPage.jumpWalletManager(context);
            },
            height: 45,
          )
        ],
      ),
    );
  }
}
