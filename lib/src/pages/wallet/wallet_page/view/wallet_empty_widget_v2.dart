import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
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
import 'package:titan/src/style/titan_sytle.dart';

class EmptyWalletViewV2 extends StatelessWidget {
  final String tips;
  final LoadDataBloc loadDataBloc;

  EmptyWalletViewV2({this.loadDataBloc, this.tips});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              child: Image.asset(
                "res/drawable/img_wallet_identity.png",
                width: 200,
              ),
            ),
          ),
          Text(
            S.of(context).private_and_safety,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 48,
            ),
            child: Text(
              tips ?? S.of(context).private_wallet_tips,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  color: HexColor('#FF9B9B9B')),
            ),
          ),
          SizedBox(
            height: 64,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: DefaultColors.colorf2f2f2,
                    width: 0.5,
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _optionItem(context, S.of(context).create_wallet, '第一次使用钱包',
                      () async {
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
                      backAndUpdatePage(context);
                    }
                  }),
                  _divider(),
                  _optionItem(context, '恢复身份', '已拥有钱包', () async {
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
                      backAndUpdatePage(context);
                    }
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _optionItem(
    BuildContext context,
    String title,
    String content,
    Function action,
  ) {
    return InkWell(
      onTap: action,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: HexColor('#FFE7BB00'),
                    ),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 11,
                      color: DefaultColors.color999,
                    ),
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: DefaultColors.colorf2f2f2,
              size: 15,
            )
          ],
        ),
      ),
    );
  }

  _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 0.5,
        width: double.infinity,
        color: DefaultColors.colorf2f2f2,
      ),
    );
  }

  backAndUpdatePage(BuildContext context) {
    var activatedWalletVo =
        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet)
            ?.activatedWallet;
    if (activatedWalletVo != null && loadDataBloc != null) {
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
