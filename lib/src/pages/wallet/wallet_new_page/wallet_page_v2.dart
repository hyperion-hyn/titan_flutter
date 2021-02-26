import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/atlas_map/widget/hyn_burn_banner.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/transfer/exchange_abnormal_transfer_list_page.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/pages/wallet/wallet_page/view/wallet_empty_widget_v2.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import '../wallet_receive_page.dart';

class WalletPageV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageV2State();
  }
}

class _WalletPageV2State extends BaseState<WalletPageV2> with AutomaticKeepAliveClientMixin {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  final LocalAuthentication auth = LocalAuthentication();

  ExchangeApi _exchangeApi = ExchangeApi();
  bool _isExchangeAccountAbnormal = false;
  bool _isShowBalances = true;
  LegalSign activeQuotesSign;
  WalletCmpBloc _walletCmpBloc;
  StreamSubscription blocSubscription;

  @override
  bool get wantKeepAlive => true;
  bool _isRefreshBalances = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    activeQuotesSign = WalletInheritedModel.of(context, aspect: WalletAspect.legal).activeLegal;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> onCreated() async {
    _walletCmpBloc = BlocProvider.of<WalletCmpBloc>(context);
    blocSubscription = _walletCmpBloc.listen((state) {
      //除了加载余额中，其它加载成功，加载失败，都走这个判断
      if (state is BalanceState && state.symbol == null && state.status != Status.loading) {
        if (mounted) {
          setState(() {
            _isRefreshBalances = false;
          });
        }
      } else if (state is BalanceState && state.symbol == null && state.status == Status.loading) {
        if (mounted) {
          setState(() {
            _isRefreshBalances = true;
          });
        }
      } else if (state is QuotesState && state.status == Status.failed) {
        if (mounted) {
          Fluttertoast.showToast(msg: S.of(context).failed_refresh_market);
        }
      }
    });
    listLoadingData();
  }

  _checkDexAccount() async {
    var activatedWalletVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).activatedWallet;

    ///get value from cache first
    _isExchangeAccountAbnormal = await AppCache.getValue(
          '${PrefsKey.EXCHANGE_ACCOUNT_ABNORMAL}${activatedWalletVo?.wallet?.getEthAccount()?.address ?? ""}',
        ) ??
        false;

    setState(() {});

    ///get value from server
    try {
      var result = await _exchangeApi.checkAccountAbnormal(
        activatedWalletVo.wallet.getEthAccount().address,
      );

      _isExchangeAccountAbnormal = result == '1';

      await AppCache.saveValue(
        '${PrefsKey.EXCHANGE_ACCOUNT_ABNORMAL}${activatedWalletVo.wallet.getEthAccount().address}',
        _isExchangeAccountAbnormal,
      );

      setState(() {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: _walletView(),
      ),
    );
  }

  _walletView() {
    return Column(
      children: <Widget>[
        _isExchangeAccountAbnormal ? _abnormalAccountBanner() : SizedBox(),
        Expanded(
          child: _buildWalletView(context),
        ),
        //hyn quotes view
        // hynQuotesView(),
        //_authorizedView(),
      ],
    );
  }

  _abnormalAccountBanner() {
    return InkWell(
      onTap: () async {
        _navigateToFixDexAccountPage();
      },
      child: Container(
        color: HexColor('#FFFFF7F8'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.warning,
                  color: HexColor('#FFFF5041'),
                ),
              ),
              Expanded(
                child: Text(
                  '${S.of(context).wallet_show_dex_account_error} >>',
                  style: TextStyle(
                    color: HexColor('#FFCE1F0F'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _navigateToFixDexAccountPage() async {
    var activatedWalletVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).activatedWallet;

    var navigateToFixPage = () async {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ExchangeAbnormalTransferListPage(
                    activatedWalletVo.wallet.getEthAccount().address,
                  )));

      ///check account is fixed when back to wallet page
      _checkDexAccount();
    };

    if (ExchangeInheritedModel.of(context).exchangeModel.hasActiveAccount()) {
      navigateToFixPage();
    } else {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => ExchangeAuthPage()));

      ///if authorized, jump to fix error page
      if (ExchangeInheritedModel.of(context).exchangeModel.hasActiveAccount()) navigateToFixPage();
    }
  }

  Widget _buildWalletView(BuildContext context) {
    var activatedWalletVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).activatedWallet;
    if (activatedWalletVo != null) {
      // if (AppLockInheritedModel.of(context).isLockActive)
      //   return Column(
      //     children: [
      //       SizedBox(height: 32),
      //       AppLockScreen(
      //         onUnlock: () {
      //           BlocProvider.of<AppLockBloc>(context).add(UnLockWalletEvent());
      //         },
      //       ),
      //     ],
      //   );
      var _hasBackupWallet = activatedWalletVo.wallet?.walletExpandInfoEntity?.isBackup ?? false;
      return Stack(children: [
        LoadDataContainer(
          bloc: loadDataBloc,
          enablePullUp: false,
          showLoadingWidget: false,
          onLoadData: () {
            // listLoadingData();
          },
          onRefresh: () async {
            listLoadingData();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              _headerWidget(activatedWalletVo),
              _chainWidget(CoinType.HYN_ATLAS),
              _tokenListByChain(activatedWalletVo, CoinType.HYN_ATLAS),
              _chainWidget(CoinType.ETHEREUM),
              _tokenListByChain(activatedWalletVo, CoinType.ETHEREUM),
              _chainWidget(CoinType.HB_HT),
              _tokenListByChain(activatedWalletVo, CoinType.HB_HT),
              _chainWidget(CoinType.BITCOIN),
              _tokenListByChain(activatedWalletVo, CoinType.BITCOIN),
              _hynBurnWidget(),
            ],
          ),
        ),
        if (!_hasBackupWallet && !Application.hasShowBackupWalletDialog)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[500],
                    blurRadius: 20.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 38,
                        height: 38,
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Image.asset(
                          "res/drawable/ic_wallet_account_backup_remind.png",
                          width: 16,
                          height: 16,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(S.of(context).safety_reminder,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: HexColor("#333333"),
                                decoration: TextDecoration.none)),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Application.hasShowBackupWalletDialog = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            "res/drawable/map3_node_close.png",
                            width: 18,
                            height: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 13, bottom: 21.0, left: 20, right: 20),
                    child: Text(S.of(context).mnemonic_not_backed_up_loss,
                        style: TextStyle(
                            fontSize: 14,
                            color: HexColor("#666666"),
                            decoration: TextDecoration.none)),
                  ),
                  ClickOvalButton(
                    S.of(context).backup_now,
                    () async {
                      setState(() {
                        Application.hasShowBackupWalletDialog = true;
                      });
                      var walletStr =
                          FluroConvertUtils.object2string(activatedWalletVo.wallet.toJson());
                      Application.router.navigateTo(
                          context,
                          Routes.wallet_setting_wallet_backup_notice +
                              '?entryRouteName=${Uri.encodeComponent(Routes.wallet_setting)}&walletStr=$walletStr');
                    },
                    btnColor: [HexColor("#E7C01A"), HexColor("#F7D33D")],
                    fontSize: 16,
                    fontColor: DefaultColors.color333,
                    width: 200,
                    height: 38,
                  ),
                  SizedBox(
                    height: 16,
                  )
                ],
              ),
            ),
          )
      ]);
    } else {
      return EmptyWalletViewV2(
        loadDataBloc: loadDataBloc,
      );
    }
  }

  _headerWidget(WalletViewVo activatedWalletVo) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Color(0xffE7C01A), Color(0xffF7D33D)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*InkWell(
              onTap: () {
                WalletManagerPage.jumpWalletManager(context, hasWalletUpdate: (wallet) {
                  setState(() {
                    // _isRefreshBalances = true;
                  });
                }, noWalletUpdate: () {
                  setState(() {});
                });
              },
              child: Row(
                children: [
                  Text(
                    activatedWalletVo?.wallet?.keystore?.name ?? "",
                    style: TextStyles.textC333S16bold,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 2.0),
                    child: Text(
                      "身份管理",
                      style: TextStyles.textC333S12,
                    ),
                  ),
                  Image.asset(
                    "res/drawable/ic_jump_arrow_right.png",
                    height: 11,
                    width: 11,
                  ),
                  Spacer(),
                  if (!_hasBackupWallet)
                    Row(
                      children: [
                        Image.asset(
                          "res/drawable/ic_remind_user.png",
                          height: 13,
                          width: 14,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "未备份",
                          style: TextStyles.textC333S12,
                        ),
                      ],
                    )
                ],
              ),
            ),*/
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      WalletManagerPage.jumpWalletManager(context);
                    },
                    child: Text(
                      "${activatedWalletVo?.wallet?.keystore?.name ?? ""}",
                      style: TextStyle(
                        fontSize: 14,
                        color: DefaultColors.color333,
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          _isShowBalances = !_isShowBalances;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 5, right: 10, bottom: 5),
                        child: Image.asset(
                          _isShowBalances
                              ? "res/drawable/ic_input_psw_show.png"
                              : "res/drawable/ic_input_psw_hide.png",
                          width: 18,
                        ),
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: Text(
                      '${activeQuotesSign?.sign ?? ''}',
                      style: TextStyle(
                          fontSize: 12, color: DefaultColors.color333, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    _isShowBalances
                        ? ' ${FormatUtil.formatPrice(activatedWalletVo.balance)}'
                        : ' *******',
                    style: TextStyle(
                        fontSize: 22, color: DefaultColors.color333, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                    color: HexColor("#8000000"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showActionDialog(WalletPageJump.PAGE_SEND, activatedWalletVo);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 27, bottom: 11, top: 12.0, right: 11),
                          child: Row(
                            children: [
                              Image.asset(
                                "res/drawable/ic_wallet_account_list_send_v3.png",
                                width: 16,
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Text(
                                S.of(context).send,
                                style: TextStyles.textC333S12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showActionDialog(WalletPageJump.PAGE_RECEIVER, activatedWalletVo);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              "res/drawable/ic_wallet_account_list_receiver_v3.png",
                              width: 18,
                            ),
                            SizedBox(width: 7),
                            Text(
                              S.of(context).receiver,
                              style: TextStyles.textC333S12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isRefreshBalances)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        listLoadingData();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3.0, bottom: 3, right: 10),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _chainWidget(int coinType) {
    var chainName = WalletUtil.getChainNameByCoinType(coinType);
    if (chainName.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Text(
            chainName,
            style: TextStyle(color: DefaultColors.color999),
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(child: SizedBox());
    }
  }

  _tokenListByChain(WalletViewVo activatedWalletVo, int coinType) {
    var tokensByCoinType = activatedWalletVo.tokensByCoinType(coinType);
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        var coinVo = tokensByCoinType[index];
        var hasPrice = true;
        return _buildAccountItem(
          context,
          coinVo,
          hasPrice: hasPrice,
          isLastIndex: tokensByCoinType.length == (index + 1),
          onTap: () {
            var coinVo = tokensByCoinType[index];
            var coinVoJsonStr = FluroConvertUtils.object2string(coinVo.toJson());
            Application.router.navigateTo(
              context,
              Routes.wallet_account_detail + '?coinVo=$coinVoJsonStr',
            );
          },
        );
      },
      childCount: tokensByCoinType.length,
    ));
  }

  _hynBurnWidget() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          HynBurnBanner(),
        ],
      ),
    );
  }

  Widget _buildAccountItem(
    BuildContext context,
    CoinViewVo coin, {
    bool hasPrice = true,
    bool isLastIndex = false,
    Function onTap,
  }) {
    var symbol = coin.symbol;
    var symbolQuote = WalletInheritedModel.of(context).tokenLegalPrice(symbol);
    var subSymbol = "";

    if (coin.coinType == CoinType.HYN_ATLAS) {
      subSymbol = '';
    } else if (coin.coinType == CoinType.ETHEREUM) {
      var symbolComponents = symbol.split(" ");
      if (symbolComponents.length == 2) {
        symbol = symbolComponents.first;
        subSymbol = symbolComponents.last.toLowerCase();
      }
    }

    var balancePrice;
    if (!hasPrice) {
      balancePrice = "";
    } else {
      balancePrice = _isShowBalances
          ? "${symbolQuote?.legal?.sign ?? ''} ${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(coin) * (symbolQuote?.price ?? 0))}"
          : '${symbolQuote?.legal?.sign ?? ''} *****';
    }

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22.0, right: 22, top: 12, bottom: 12),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: 48,
                            height: 48,
                            child: ImageUtil.getCoinImage(coin.logo),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ImageUtil.getChainIcon(coin, 18),
                          )
                        ],
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                symbol,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF252525)),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                subSymbol,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              _isShowBalances
                                  ? "${FormatUtil.coinBalanceHumanReadFormat(coin)}"
                                  : '*****',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                balancePrice,
                                style: TextStyles.textC9b9b9bS12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    if (coin.refreshStatus == Status.failed)
                      InkWell(
                        onTap: () {
                          BlocProvider.of<WalletCmpBloc>(context)
                              .add(UpdateActivatedWalletBalanceEvent(symbol: symbol));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                BlocProvider.of<WalletCmpBloc>(context)
                                    .add(UpdateActivatedWalletBalanceEvent(symbol: symbol));
                              },
                              child: Text(
                                S.of(context).failed_to_load,
                                style: TextStyle(color: HexColor("#FF1A1A"), fontSize: 12),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Icon(
                                Icons.refresh,
                                size: 16,
                                color: HexColor("#AAAAAA"),
                              ),
                            )
                          ],
                        ),
                      ),
                    if (coin.refreshStatus == Status.loading && !_isRefreshBalances)
                      SizedBox(
                        height: 19,
                        width: 19,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: new AlwaysStoppedAnimation<Color>(DefaultColors.colore7bb00),
                          strokeWidth: 1,
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
          if (!isLastIndex)
            Container(
              margin: EdgeInsets.only(
                left: 24,
                right: 32,
              ),
              height: 0.5,
              color: HexColor('#F2F2F2'),
            )
        ],
      ),
    );
  }

  void _showActionDialog(WalletPageJump jumpType, WalletViewVo activatedWalletVo) {
    String titleStr = "";
    switch (jumpType) {
      case WalletPageJump.PAGE_SEND:
        titleStr = S.of(context).send;
        break;
      case WalletPageJump.PAGE_RECEIVER:
        titleStr = S.of(context).receiver;
        break;
      case WalletPageJump.PAGE_EXCHANGE:
        titleStr = S.of(context).transaction;
        break;
    }
    UiUtil.showBottomDialogView(
      context,
      dialogHeight: MediaQuery.of(context).size.height - 90,
      isScrollControlled: true,
      customWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Center(child: Text(titleStr, style: TextStyles.textC999S14medium)),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                _chainWidget(CoinType.HYN_ATLAS),
                _dialogTokenListByChain(activatedWalletVo, CoinType.HYN_ATLAS, jumpType),
                _chainWidget(CoinType.ETHEREUM),
                _dialogTokenListByChain(activatedWalletVo, CoinType.ETHEREUM, jumpType),
                _chainWidget(CoinType.HB_HT),
                _dialogTokenListByChain(activatedWalletVo, CoinType.HB_HT, jumpType),
                _chainWidget(CoinType.BITCOIN),
                _dialogTokenListByChain(activatedWalletVo, CoinType.BITCOIN, jumpType),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _dialogTokenListByChain(WalletViewVo activatedWalletVo, int coinType, WalletPageJump jumpType) {
    var tokensByCoinType = activatedWalletVo.tokensByCoinType(coinType);
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        var coinVo = tokensByCoinType[index];
        var hasPrice = true;
        return _buildAccountItem(context, coinVo,
            hasPrice: hasPrice, isLastIndex: tokensByCoinType.length == (index + 1), onTap: () {
          var coinVo = tokensByCoinType[index];
          switch (jumpType) {
            case WalletPageJump.PAGE_SEND:
              Application.router.navigateTo(
                  context,
                  Routes.wallet_account_send_transaction +
                      '?coinVo=${FluroConvertUtils.object2string(coinVo.toJson())}&entryRouteName=${Uri.encodeComponent(Routes.wallet_account_detail)}');
              break;
            case WalletPageJump.PAGE_RECEIVER:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => WalletReceivePage(coinVo)));
              break;
            case WalletPageJump.PAGE_EXCHANGE:
              if ((coinVo.symbol == DefaultTokenDefine.HYN_Atlas.symbol) ||
                  (coinVo.symbol == DefaultTokenDefine.HYN_RP_HRC30.symbol)) {
                var base = 'USDT';
                var quote = 'HYN';
                if (coinVo.symbol == DefaultTokenDefine.HYN_RP_HRC30.symbol) {
                  base = 'HYN';
                  quote = 'RP';
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExchangeDetailPage(
                              base: base,
                              quote: quote,
                              exchangeType: ExchangeType.BUY,
                            )));
              } else {
                Fluttertoast.showToast(msg: S.of(context).exchange_is_not_yet_open(coinVo.symbol));
              }
              break;
          }
        });
      },
      childCount: tokensByCoinType.length,
    ));
  }

  Future listLoadingData() async {
    _checkDexAccount();
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
    await Future.delayed(Duration(milliseconds: 50), () {});
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateQuotesEvent());

    if (mounted) {
      loadDataBloc.add(RefreshSuccessEvent());
    }
  }

  Widget loadingView(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    blocSubscription.cancel();
    loadDataBloc.close();
    // _walletCmpBloc.close();
    super.dispose();
  }
}

enum WalletPageJump {
  PAGE_SEND,
  PAGE_RECEIVER,
  PAGE_EXCHANGE,
}
