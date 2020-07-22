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
  final ExchangeBloc exchangeBloc;

  ExchangeAuthPage(this.exchangeBloc);

  @override
  State<StatefulWidget> createState() {
    return _ExchangeAuthPageState();
  }
}

class _ExchangeAuthPageState extends BaseState<ExchangeAuthPage> {
  bool _isNoWallet = false;

  @override
  Future<void> onCreated() async {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isWalletListEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isNoWallet ? _noWalletView() : _authorizeView(),
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
          ClickOvalButton(
            '使用钱包授权登录',
            () async {
              var wallet = WalletInheritedModel.of(context).activatedWallet;
              if (wallet != null) {
                var address = wallet.wallet.getEthAccount().address;
                var walletPassword = await UiUtil.showWalletPasswordDialogV2(
                    context, wallet.wallet);

                ExchangeApi _exchangeApi = ExchangeApi();

                try {
                  var ret = await _exchangeApi.walletSignLogin(
                    wallet: wallet.wallet,
                    password: walletPassword,
                    address: address,
                  );
                  var account = ExchangeAccount.fromJson(ret);

                  print('使用钱包授权登录: account: $account');

                  if (account != null) {
                    Fluttertoast.showToast(msg: '登录成功!');
                    BlocProvider.of<ExchangeCmpBloc>(context)
                        .add(UpdateExchangeAccountEvent(account));

                    BlocProvider.of<ExchangeCmpBloc>(context)
                        .add(UpdateAssetsEvent());
                  }
                } catch (e) {}
              }

              ///
              widget.exchangeBloc.add(SwitchToContentEvent());
            },
            height: 45,
          )
        ],
      ),
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
              ///
              widget.exchangeBloc.add(SwitchToContentEvent());

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

  _isWalletListEmpty() async {
    var wallets = await WalletUtil.scanWallets();
    print('_isWalletListEmpty: ${wallets.length}');
    _isNoWallet = wallets.length == 0;
    setState(() {});
  }
}