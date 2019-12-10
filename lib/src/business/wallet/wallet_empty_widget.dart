import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/wallet/wallet_import_account_page.dart';
import 'package:titan/src/global.dart';

import 'wallet_create_new_account_page.dart';

class EmptyWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EmptyWalletState();
  }
}

class _EmptyWalletState extends State<EmptyWallet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Container(
            width: 73,
            height: 86,
            child: Image.asset(
              "res/drawable/safe_lock.png",
              width: 72,
            ),
          ),
        ),
        Text(
          S.of(context).private_and_safety,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            S.of(context).private_wallet_tips,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey[400]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(36)),
                onPressed: () {
                  createWalletPopUtilName = null;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                    child: Text(
                      S.of(context).create_wallet,
                      style:
                          TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(36)),
                  onPressed: () {
                    createWalletPopUtilName = null;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).import_wallet,
                        style:
                            TextStyle(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
