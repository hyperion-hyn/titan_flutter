import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';

import 'wallert_create_new_account_page.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WalletPageState();
  }
}

class _WalletPageState extends State<WalletPage> {
  WalletBloc _walletBloc;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _buildWalletView(context);
  }

  @override
  void initState() {
    _walletBloc = WalletBloc();
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
                    child: _buildEmptyWallet(context),
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

  Widget _buildEmptyWallet(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.account_balance_wallet,
            color: Colors.black,
            size: 70,
          ),
          Container(
              width: 220,
              child: Text(
                "HYN钱包是基于以太坊ERC20的离线钱包，使用钱包可以支付地图购买，投资节点等",
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 3,
              )),
          Container(
            height: 200,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 16.0),
                    child: Text(
                      "创建钱包",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                color: Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "导入钱包",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
