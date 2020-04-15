import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class FinishCreatePage extends StatelessWidget {
  final Wallet wallet;

  FinishCreatePage(this.wallet);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Routes.popUntilCachedEntryRouteName(context, wallet);
                },
              );
            },
          ),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Image.asset(
                    "res/drawable/check_outline.png",
                    height: 76,
                    width: 124,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    S.of(context).wallet_create_success,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S.of(context).wallet_create_success_tips,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9B9B9B)),
                  ),
                ),
                SizedBox(
                  height: 36,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                  constraints: BoxConstraints.expand(height: 48),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () async {
                      BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: wallet));

                      Routes.popUntilCachedEntryRouteName(context, wallet);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).user_this_account,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
