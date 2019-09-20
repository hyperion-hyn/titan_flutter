import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallet_show_account_widget.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

import 'model_vo.dart';
import 'wallert_create_new_account_page.dart';
import 'wallert_import_account_page.dart';

class ShowWallet extends StatefulWidget {
  WalletVo wallet;

  ShowWallet(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _ShowWalletState();
  }
}

class _ShowWalletState extends State<ShowWallet> {
  WalletVo wallet;

  @override
  void initState() {
    wallet = widget.wallet;
  }

  @override
  Widget build(BuildContext context) {
    TrustWalletKeyStore walletKeyStore = wallet.wallet.keystore;
    var walletName = walletKeyStore.name;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Text(
                            "${wallet.amountUnit} \$${sprintf("%.2", [wallet.amount])}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${walletName}"),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 8,
                  child: Text(
                    "管理",
                    style: TextStyle(color: HexColor("#FF3F51B5")),
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 2,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowAccountPage()));
                  },
                  child: _buildAccountItem(context, wallet.accountList[index]));
            },
            itemCount: wallet.accountList.length,
          )
        ]);
  }

  Widget _buildAccountItem(BuildContext context, WalletAccountVo account) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              shape: BoxShape.circle,
            ),
            child: Text(account.symbol),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  account.name,
                  style: TextStyle(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${account.priceUnit}${account.price}",
                    style: TextStyle(fontSize: 11, color: HexColor("#FF848181")),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Ethereum",
                  style: TextStyle(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "USD180.92",
                    style: TextStyle(fontSize: 11, color: HexColor("#FF848181")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
