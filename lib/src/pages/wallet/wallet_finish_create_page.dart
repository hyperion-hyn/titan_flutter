import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/utils/log_util.dart';

class FinishCreatePage extends StatelessWidget {
  final Wallet wallet;

  FinishCreatePage(this.wallet);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  onClosePage(context,false);
                },
              );
            },
          ),
        ),
        body: WillPopScope(
          onWillPop: () {
            onClosePage(context,false);
            return;
          },
          child: Center(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Image.asset(
                      "res/drawable/check_outline.png",
                      width: 124,
                      height: 76,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      S.of(context).wallet_create_success,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      disabledColor: Colors.grey[600],
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      disabledTextColor: Colors.white,
                      onPressed: () async {
                        onClosePage(context,true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).user_this_account,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void onClosePage(BuildContext context, bool isClickActive) async {
    List<Wallet> walletList = await WalletUtil.scanWallets();
    if (walletList.length == 1 || isClickActive) {
      BlocProvider.of<WalletCmpBloc>(context)
          .add(ActiveWalletEvent(wallet: wallet));

      ///Use digits password now
      WalletUtil.useDigitsPwd(wallet);

      ///Clear exchange account when switch wallet
      BlocProvider.of<ExchangeCmpBloc>(context)
          .add(ClearExchangeAccountEvent());

      await Future.delayed(Duration(milliseconds: 300));
      BlocProvider.of<WalletCmpBloc>(context)
          .add(UpdateActivatedWalletBalanceEvent());
    }

    try {
      if(MemoryCache.rpInviteKey != null) {
        RPApi _rpApi = RPApi();
        String inviteResult = await _rpApi.postRpInviter(MemoryCache.rpInviteKey, wallet);
        if(inviteResult != null) {
          Fluttertoast.showToast(msg: "邀请成功");
          MemoryCache.rpInviteKey = null;
        }
      }
    }catch(error){
      LogUtil.toastException(error);
    }

    var userPayload = UserPayloadWithAddressEntity(Payload(userName: wallet.keystore.name),wallet.getAtlasAccount().address);
    AtlasApi.postUserSync(userPayload);
    Routes.popUntilCachedEntryRouteName(context, wallet);
  }
}
