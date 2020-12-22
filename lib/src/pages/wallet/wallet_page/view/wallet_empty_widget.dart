import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

class EmptyWalletView extends StatelessWidget {
  final String tips;
  final LoadDataBloc loadDataBloc;

  EmptyWalletView({this.loadDataBloc,this.tips});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
            child: Text(
              tips ?? S.of(context).private_wallet_tips,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(36)),
                  onPressed: () async {
                    if (await _checkConfirmWalletPolicy()) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PolicyConfirmPage(
                          PolicyType.WALLET,
                        ),
                      ));
                    } else {
                      var currentRouteName =
                          RouteUtil.encodeRouteNameWithoutParams(context);
                      await Application.router.navigateTo(
                        context,
                        Routes.wallet_create +
                            '?entryRouteName=$currentRouteName',
                      );
                      backAndupdatePage(context);
                    }
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      S.of(context).create_wallet,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(36)),
                    onPressed: () async {
                      if (await _checkConfirmWalletPolicy()) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => PolicyConfirmPage(
                            PolicyType.WALLET,
                          ),
                        ));
                      } else {
                        var currentRouteName =
                            RouteUtil.encodeRouteNameWithoutParams(context);
                        Application.router.navigateTo(
                          context,
                          Routes.wallet_import +
                              '?entryRouteName=$currentRouteName',
                        );
                        backAndupdatePage(context);
                      }
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        S.of(context).import_wallet,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  backAndupdatePage(BuildContext context){
    var activatedWalletVo =
        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet)
            ?.activatedWallet;
    if(activatedWalletVo != null && loadDataBloc != null) {
      loadDataBloc.add(LoadingEvent());
    }
  }

  Future<bool> _checkConfirmWalletPolicy() async {
    var isConfirmWalletPolicy = await AppCache.getValue(
      PrefsKey.IS_CONFIRM_WALLET_POLICY,
    );
    return isConfirmWalletPolicy == null || !isConfirmWalletPolicy;
  }
}
