import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/pages/wallet/wallet_page/view/wallet_empty_widget.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/wallet/wallet_manager/bloc/bloc.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:characters/characters.dart';

class WalletManagerPage extends StatefulWidget {
  final String tips;

  WalletManagerPage({this.tips});

  @override
  State<StatefulWidget> createState() {
    return _WalletManagerState();
  }
}

class _WalletManagerState extends BaseState<WalletManagerPage> with RouteAware {
  WalletManagerBloc _walletManagerBloc;
  bool isRefresh = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

//  @override
//  void onCreated() {
//    _walletManagerBloc = BlocProvider.of<WalletManagerBloc>(context);
//    _walletManagerBloc.add(ScanWalletEvent());
//  }

  @override
  void didPush() {
    _walletManagerBloc = BlocProvider.of<WalletManagerBloc>(context);
    _walletManagerBloc.add(ScanWalletEvent());

    BlocProvider.of<WalletCmpBloc>(context).listen((state) {
      if (state is ActivatedWalletState) {
        isRefresh = false;
      }
    });
    super.didPush();
  }

  @override
  void didPopNext() {
    _walletManagerBloc.add(ScanWalletEvent());
    super.didPushNext();
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    _walletManagerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext cofntext) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            S.of(context).wallet_manage,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () async {
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
                          '?entryRouteName=$currentRouteName');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  ExtendsIconFont.import,
                  size: 18,
                ),
              ),
            ),
            SizedBox(
              width: 4.0,
            ),
            InkWell(
              onTap: () async {
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
                      Routes.wallet_create +
                          '?entryRouteName=$currentRouteName');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  ExtendsIconFont.add,
                  size: 20,
                ),
              ),
            ),
            SizedBox(
              width: 8,
            )
          ],
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: BlocBuilder<WalletManagerBloc, WalletManagerState>(
            bloc: _walletManagerBloc,
            builder: (context, state) {
              if (state is ShowWalletState) {
                var walletList = state.wallets;
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildWallet(walletList[index]);
                        },
                        itemCount: walletList.length,
                      ),
                    ),
                    if(isRefresh)
                      Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                );
              } else if (state is WalletEmptyState) {
                return Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: EmptyWalletView(tips: widget.tips),
                    ));
              } else {
                return Container();
              }
            },
          ),
        ));
  }

  Widget _buildWallet(Wallet wallet) {
    bool isSelected = wallet.keystore.fileName ==
        WalletInheritedModel.of(context)
            .activatedWallet
            ?.wallet
            ?.keystore
            ?.fileName;
    KeyStore walletKeyStore = wallet.keystore;
    Account ethAccount = wallet.getEthAccount();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (!isSelected) {
                      UiUtil.showAlertView(
                        context,
                        title: S.of(context).tips,
                        actions: [
                          ClickOvalButton(
                            S.of(context).cancel,
                                () {
                              Navigator.pop(context);
                            },
                            width: 120,
                            height: 32,
                            fontSize: 14,
                            fontColor: DefaultColors.color999,
                            btnColor: [Colors.transparent],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          ClickOvalButton(
                            "切换钱包",
                                () async {
                              Navigator.pop(context);

                              var password = await UiUtil.showWalletPasswordDialogV2(
                                context,
                                wallet,
                              );
                              if(password == null || password.isEmpty){
                                return;
                              }
                              isRefresh = true;
                              setState(() {
                              });

                              BlocProvider.of<WalletCmpBloc>(context)
                                  .add(ActiveWalletEvent(wallet: wallet));
                              ///Clear exchange account when switch wallet
                              BlocProvider.of<ExchangeCmpBloc>(context)
                                  .add(ClearExchangeAccountEvent());
                            },
                            width: 120,
                            height: 38,
                            fontSize: 16,
                          ),
                        ],
                        content: "你将要切换${walletKeyStore.name}为当前钱包，继续切换吗？",
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor),
                        width: 45,
                        height: 45,
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: walletHeaderWidget(
                                walletKeyStore.name.isEmpty
                                    ? "Name is empty"
                                    : walletKeyStore.name.characters.first,
                                address: ethAccount.address,
                                size: 52,
                                fontSize: 20,
                              ),
                            ),
                            if (isSelected)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              walletKeyStore.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF252525)),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                shortBlockChainAddress(
                                    WalletUtil.ethAddressToBech32Address(
                                  ethAccount.address,
                                )),
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF9B9B9B)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  var walletStr =
                      FluroConvertUtils.object2string(wallet.toJson());
                  var currentRouteName =
                      RouteUtil.encodeRouteNameWithoutParams(context);

                  Application.router.navigateTo(
                      context,
                      Routes.wallet_setting +
                          '?entryRouteName=$currentRouteName&walletStr=$walletStr');
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

  Future<bool> _checkConfirmWalletPolicy() async {
    var isConfirmWalletPolicy = await AppCache.getValue(
      PrefsKey.IS_CONFIRM_WALLET_POLICY,
    );
    return isConfirmWalletPolicy == null || !isConfirmWalletPolicy;
  }
}
