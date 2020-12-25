import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
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

  static Future jumpWalletManager(BuildContext context,{void hasWalletUpdate(Wallet wallet),Function noWalletUpdate}) async {
    Wallet wallet = await Application.router.navigateTo(
      context,
      Routes.wallet_manager,
    );
    if(wallet != null) {
      if(hasWalletUpdate != null){
        hasWalletUpdate(wallet);
      }
      BlocProvider.of<WalletCmpBloc>(context)
          .add(ActiveWalletEvent(wallet: wallet));
      await Future.delayed(Duration(milliseconds: 300));
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletPageEvent());

      ///Clear exchange account when switch wallet
      BlocProvider.of<ExchangeCmpBloc>(context)
          .add(ClearExchangeAccountEvent());
    }else{
      if(noWalletUpdate != null){
        noWalletUpdate();
      }
    }
  }
}

class _WalletManagerState extends BaseState<WalletManagerPage> with RouteAware {
  WalletManagerBloc _walletManagerBloc;
  //一开始进入当前页面激活的钱包
  Wallet beforeActiveWallet;
  //切换选中的钱包
  Wallet selectWallet;

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
    beforeActiveWallet = WalletInheritedModel.of(context)
        .activatedWallet
        ?.wallet;
    _walletManagerBloc = BlocProvider.of<WalletManagerBloc>(context);
    _walletManagerBloc.add(ScanWalletEvent());

    super.didPush();
  }

  @override
  void didPopNext() async {
    _walletManagerBloc.add(ScanWalletEvent());

    var currentActiveWallet = WalletInheritedModel.of(context)
        .activatedWallet
        ?.wallet;
    if(currentActiveWallet?.keystore?.fileName != beforeActiveWallet?.keystore?.fileName){
      //激活钱包发生变化，切换激活钱包
      beforeActiveWallet = currentActiveWallet;
      //将变化钱包作为选中钱包
      selectWallet = currentActiveWallet;
    }
    super.didPushNext();
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    _walletManagerBloc.close();
    super.dispose();
  }

  void listenBackAction(){
    Navigator.pop(context,selectWallet);
  }

  @override
  Widget build(BuildContext cofntext) {
    return Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).wallet_manage,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  listenBackAction();
                },
              );
            },
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
        body: WillPopScope(
          onWillPop: () async {
            listenBackAction();
            return false;
          },
          child: Container(
            height: double.infinity,
            //color: Colors.white,
            child: BlocBuilder<WalletManagerBloc, WalletManagerState>(
              bloc: _walletManagerBloc,
              builder: (context, state) {
                if (state is ShowWalletState) {
                  var walletList = state.wallets;
                  return ListView.separated(
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildWallet(walletList[index], index:index);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 30,
                        ),
                        child: Container(
                          height: 0.8,
                          color: HexColor('#F8F8F8'),
                        ),
                      );
                    },
                    itemCount: walletList.length,
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
          ),
        ));
  }

  Widget _buildWallet(Wallet wallet,{int index = 0}) {
    var walletFileName = selectWallet?.keystore?.fileName ?? beforeActiveWallet.keystore.fileName ?? "";
    bool isSelected = (wallet.keystore.fileName == walletFileName);
    KeyStore walletKeyStore = wallet.keystore;
    Account ethAccount = wallet.getEthAccount();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (index == 0) Container(
            height: 5,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8,),
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

                                    setState(() {
                                      selectWallet = wallet;
                                    });
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
                //Divider()
              ],
            ),
          ),
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