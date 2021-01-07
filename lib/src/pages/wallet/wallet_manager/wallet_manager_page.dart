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
import 'package:titan/src/pages/wallet/wallet_page/view/wallet_empty_widget_v2.dart';
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
import 'package:titan/src/widget/popup/pop_route.dart';
import 'package:titan/src/widget/popup/pop_widget.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:characters/characters.dart';

class WalletManagerPage extends StatefulWidget {
  final String tips;

  WalletManagerPage({this.tips});

  @override
  State<StatefulWidget> createState() {
    return _WalletManagerState();
  }

  static Future jumpWalletManager(BuildContext context,
      {void hasWalletUpdate(Wallet wallet), Function noWalletUpdate}) async {
    Wallet wallet = await Application.router.navigateTo(
      context,
      Routes.wallet_manager,
    );
    if (wallet != null) {
      if (hasWalletUpdate != null) {
        hasWalletUpdate(wallet);
      }
      BlocProvider.of<WalletCmpBloc>(context)
          .add(ActiveWalletEvent(wallet: wallet));
      await Future.delayed(Duration(milliseconds: 300));
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletPageEvent());

      ///Clear exchange account when switch wallet
      BlocProvider.of<ExchangeCmpBloc>(context)
          .add(ClearExchangeAccountEvent());
    } else {
      if (noWalletUpdate != null) {
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
    beforeActiveWallet =
        WalletInheritedModel.of(context).activatedWallet?.wallet;
    _walletManagerBloc = BlocProvider.of<WalletManagerBloc>(context);
    _walletManagerBloc.add(ScanWalletEvent());

    super.didPush();
  }

  @override
  void didPopNext() async {
    _walletManagerBloc.add(ScanWalletEvent());

    var currentActiveWallet =
        WalletInheritedModel.of(context).activatedWallet?.wallet;
    if (currentActiveWallet?.keystore?.fileName !=
        beforeActiveWallet?.keystore?.fileName) {
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

  void listenBackAction() {
    Navigator.pop(context, selectWallet);
  }

  @override
  Widget build(BuildContext cofntext) {
    return Scaffold(
        appBar: BaseAppBar(
          backgroundColor: HexColor('#F6F6F6'),
          baseTitle: S.of(context).wallet_manage,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () async {
                  listenBackAction();
                },
              );
            },
          ),
          actions: <Widget>[
            InkWell(
              onTap: () async {
                _showOptionsPopup();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'res/drawable/ic_more_actions.png',
                  width: 18,
                  height: 18,
                ),
              ),
            ),
            SizedBox(
              width: 16,
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
            color: HexColor('#F6F6F6'),
            child: BlocBuilder<WalletManagerBloc, WalletManagerState>(
              bloc: _walletManagerBloc,
              builder: (context, state) {
                if (state is ShowWalletState) {
                  var walletList = state.wallets;
                  return CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _walletItem(walletList[index]);
                          },
                          childCount: walletList.length,
                        ),
                      ),
                    ],
                  );
                } else if (state is WalletEmptyState) {
                  return _emptyView();
                } else {
                  return Container();
                }
              },
            ),
          ),
        ));
  }

  _createWallet() async {
    if (await _checkConfirmWalletPolicy()) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PolicyConfirmPage(
          PolicyType.WALLET,
        ),
      ));
    } else {
      var currentRouteName = RouteUtil.encodeRouteNameWithoutParams(context);
      Application.router.navigateTo(
          context,
          Routes.wallet_create +
              '?entryRouteName=$currentRouteName&isCreate=1');
    }
  }

  _importWallet() async {
    if (await _checkConfirmWalletPolicy()) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PolicyConfirmPage(
          PolicyType.WALLET,
        ),
      ));
    } else {
      var currentRouteName = RouteUtil.encodeRouteNameWithoutParams(context);
      Application.router.navigateTo(
          context, Routes.wallet_create + '?entryRouteName=$currentRouteName');
    }
  }

  _showOptionsPopup() {
    var screenWidth = MediaQuery.of(context).size.width;
    return Navigator.push(
      context,
      PopRoute(
        child: Popup(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Container(
              // constraints: BoxConstraints(
              //   maxWidth: 150,
              // ),
              width: 135,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      ///close popup
                      Navigator.of(context).pop();
                      _createWallet();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'res/drawable/ic_create_wallet.png',
                            width: 18,
                            height: 18,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              child: Text(
                            S.of(context).create_wallet,
                          )),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _importWallet();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        children: [
                          Image.asset(
                            'res/drawable/ic_import_wallet.png',
                            width: 18,
                            height: 18,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              child: Text(
                            S.of(context).import_wallet,
                          )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          left: screenWidth - 150,
          top: 64,
        ),
      ),
    );
  }

  _emptyView() {
    var topPadding = MediaQuery.of(context).size.height / 5;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          Image.asset(
            'res/drawable/ic_empty_data.png',
            width: 100,
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              S.of(context).no_data,
              style: TextStyle(color: DefaultColors.color999),
            ),
          ),
        ],
      ),
    );
  }

  _switchWallet(Wallet wallet) {
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
            if (password == null || password.isEmpty) {
              return;
            }

            setState(() {
              selectWallet = wallet;
            });
          },
          width: 120,
          height: 38,
          fontSize: 16,
          fontColor: Colors.black,
          btnColor: [
            HexColor("#F7D33D"),
            HexColor("#E7C01A"),
          ],
        ),
      ],
      content: "你将要切换${wallet.keystore.name}为当前钱包，继续切换吗？",
    );
  }

  Widget _walletItem(
    Wallet wallet, {
    int index = 0,
  }) {
    var walletFileName = selectWallet?.keystore?.fileName ??
        beforeActiveWallet.keystore.fileName ??
        "";
    bool isSelected = (wallet.keystore.fileName == walletFileName);
    KeyStore walletKeyStore = wallet.keystore;
    Account ethAccount = wallet.getEthAccount();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (!isSelected) {
                      _switchWallet(wallet);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
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
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    child: Image.asset(
                                      'res/drawable/ic_check_selected.png',
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              walletKeyStore.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(
                                    0xFF252525,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              child: Text(
                                shortBlockChainAddress(
                                  WalletUtil.ethAddressToBech32Address(
                                    ethAccount.address,
                                  ),
                                  limitCharsLength: 6,
                                ),
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF9B9B9B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FutureBuilder(
                          future: WalletUtil.checkIsBackUpMnemonic(
                            ethAccount.address,
                          ),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              bool result = snapshot.data;
                              return result
                                  ? SizedBox()
                                  : Row(
                                      children: [
                                        Image.asset(
                                          'res/drawable/ic_warning_triangle_v2.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '未备份',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: HexColor('#E7BB00'),
                                          ),
                                        ),
                                      ],
                                    );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
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
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 4.0,
                  ),
                  child: Image.asset(
                    'res/drawable/k_line_setting.png',
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
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
