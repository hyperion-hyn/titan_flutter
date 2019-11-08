import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_manager/bloc/bloc.dart';
import 'package:titan/src/business/wallet/wallet_setting.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/utils/utils.dart';

class WalletManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletManagerState();
  }
}

class _WalletManagerState extends State<WalletManagerPage> {
  WalletManagerBloc _walletManagerBloc = WalletManagerBloc();

  @override
  void initState() {
    _walletManagerBloc.add(ScanWalletEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            "钱包管理",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: BlocBuilder<WalletManagerBloc, WalletManagerState>(
          bloc: _walletManagerBloc,
          builder: (context, walletManagerState) {
            if (walletManagerState is ShowWalletState) {
              var walletList = walletManagerState.wallets;
              return ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return _buildWallet(walletList[index]);
                },
                itemCount: walletList.length,
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Widget _buildWallet(Wallet wallet) {
    Wallet trustWallet = wallet;
    KeyStore walletKeyStore = trustWallet.keystore;
    Account ethAccount = trustWallet.getEthAccount();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 52,
                height: 52,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF4F4F4)),
                child: Text("HYN"),
              ),
              SizedBox(
                width: 12,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      walletKeyStore.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF252525)),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        shortEthAddress(ethAccount.address),
                        style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WalletSettingPage(trustWallet)));
                },
                child: Icon(
                  Icons.info_outline,
                  color: Color(0xFF9B9B9B),
                ),
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
