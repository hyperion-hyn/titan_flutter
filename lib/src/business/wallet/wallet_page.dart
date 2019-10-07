import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallert_import_account_page.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/business/wallet/wallet_empty_widget.dart';
import 'package:titan/src/business/wallet/wallet_show_widget.dart';

import 'wallert_create_new_account_page.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

class _WalletPageState extends State<WalletPage> {
  WalletBloc _walletBloc;

  @override
  Widget build(BuildContext context) {
    return _buildWalletView(context);
  }

  @override
  void initState() {
    _walletBloc = WalletBloc();

    _walletBloc.dispatch(ScanWalletEvent());
  }

  Widget _buildWalletView(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          textTheme: TextTheme(),
          backgroundColor: Colors.white,
          title: TabBar(
            labelColor: Colors.blue,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(
                  child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.account_balance_wallet,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "钱包",
                      ),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            BlocBuilder<WalletBloc, WalletState>(
              bloc: _walletBloc,
              builder: (BuildContext context, WalletState state) {
                if (state is WalletEmptyState) {
                  return Container(
                    alignment: Alignment.center,
                    child: EmptyWallet(),
                  );
                } else if (state is ShowWalletState) {
                  return Container(
                    child: ShowWallet(state.wallet),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
