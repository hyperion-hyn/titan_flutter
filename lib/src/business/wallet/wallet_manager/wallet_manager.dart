import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/business/wallet/wallet_manager/bloc/bloc.dart';
import 'package:titan/src/business/wallet/wallet_setting.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';

import '../wallet_import_account_page.dart';

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
    initData();
    super.initState();
  }

  void initData() {}

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
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  ExtendsIconFont.import,
                  size: 20,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(ExtendsIconFont.add),
              ),
            ),
            SizedBox(
              width: 8,
            )
          ],
        ),
        body: BlocBuilder<WalletManagerBloc, WalletManagerState>(
          bloc: _walletManagerBloc,
          builder: (context, walletManagerState) {
            if (walletManagerState is ShowWalletState) {
              var defaultWalletFileName = walletManagerState.defaultWalletFileName;
              var walletList = walletManagerState.wallets;
              return ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return _buildWallet(walletList[index], defaultWalletFileName);
                },
                itemCount: walletList.length,
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Widget _buildWallet(Wallet wallet, String defaultWalletFileName) {
    Wallet trustWallet = wallet;
    KeyStore walletKeyStore = trustWallet.keystore;
    Account ethAccount = trustWallet.getEthAccount();
    var isSelected = (wallet.keystore.fileName == defaultWalletFileName);
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
                child: InkWell(
                  onTap: () {
                    if (!isSelected) {
                      _walletManagerBloc.add(SwitchWalletEvent(wallet));
                    }
                  },
                  child: Stack(
                    children: <Widget>[
                      Align(alignment: Alignment.center, child: Text("HYN")),
                      if (isSelected)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                    ],
                  ),
                ),
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
