import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_abnormal_transfer_list_page.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_safe_lock.dart';
import 'package:titan/src/pages/wallet/wallet_page/view/wallet_empty_widget_v2.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class WalletPageV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageV2State();
  }
}

class _WalletPageV2State extends BaseState<WalletPageV2>
    with AutomaticKeepAliveClientMixin {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  final LocalAuthentication auth = LocalAuthentication();

  ExchangeApi _exchangeApi = ExchangeApi();
  bool _isExchangeAccountAbnormal = false;
  bool _isSafeLockUnlock = false;
  bool _isShowBalances = true;
  bool _hasBackupWallet = false;
  QuotesSign activeQuotesSign;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    activeQuotesSign =
        WalletInheritedModel.of(context, aspect: WalletAspect.sign)
            .activeQuotesSign;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> onCreated() async {
    _postWalletBalance();

    // listLoadingData();
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

  Future<void> _postWalletBalance() async {
    //appType:  0:titan; 1:star

    if (context == null) return;

    var activatedWalletVo =
        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet)
            ?.activatedWallet;

    if (activatedWalletVo == null) return;

    String address = activatedWalletVo.wallet.getEthAccount().address;
    int appType = 0;
    String email = "titan";
    String hynBalance = "0";
    LogUtil.printMessage(
        "[API] address:$address, hynBalance:$hynBalance, email:$email");

    // 同步用户钱包信息
    if (address.isNotEmpty) {
      var hynCoinVo = WalletInheritedModel.of(context).getCoinVoBySymbol("HYN");
      LogUtil.printMessage(
          "object] balance1: ${hynCoinVo.balance}, decimal:${hynCoinVo.decimals}");
      var balance = FormatUtil.coinBalanceDouble(hynCoinVo);
      balance = 0;
      if (balance <= 0) {
        var balanceValue = await activatedWalletVo.wallet
            .getErc20Balance(hynCoinVo.contractAddress);
        balance = ConvertTokenUnit.weiToDecimal(
                balanceValue ?? 0, hynCoinVo?.decimals ?? 0)
            .toDouble();
        LogUtil.printMessage("object] balance2: $balance");
      }
      hynBalance = balance.toString();
      BitcoinApi.postWalletBalance(address, appType, email, hynBalance);
    }
  }

  _showBackupDialog() async {
    var activatedWalletVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).activatedWallet;
    _hasBackupWallet = await WalletUtil.checkIsBackUpMnemonic(activatedWalletVo?.wallet?.getEthAccount()?.address ?? "");
    if(activatedWalletVo == null || _hasBackupWallet || Application.hasShowBackupWalletDialog){
      return;
    }
    Application.hasShowBackupWalletDialog = true;
    await UiUtil.showAlertViewNew(context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        isShowBottom: true,
        contentWidget: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("res/drawable/ic_wallet_account_backup_remind.png",width: 16,height: 16,),
                  SizedBox(width: 6,),
                  Text("安全提醒",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: HexColor("#333333"),
                          decoration: TextDecoration.none)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:13,bottom:21.0,left: 20,right: 20),
              child: Text(
                  "你的身份助记词未备份，请务必备份助记词\n助记词可用于恢复身份钱包资产，防止忘记密码、应用删除、手机丢失等情况导致资产损失。",
                  style: TextStyle(
                      fontSize: 14,
                      color: HexColor("#666666"),
                      decoration: TextDecoration.none)),
            ),
          ],
        ),
        actions: [
          ClickOvalButton(
            "立即备份",
            () async {
              Navigator.pop(context);
              var walletStr = FluroConvertUtils.object2string(activatedWalletVo.wallet.toJson());
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
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isSafeLockUnlock){
      Future.delayed(Duration(milliseconds: 1000), () {
        _showBackupDialog();
      });
    }

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
        SizedBox(
          height: 16,
        ),
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
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => ExchangeAuthPage()));

      ///if authorized, jump to fix error page
      if (ExchangeInheritedModel.of(context).exchangeModel.hasActiveAccount())
        navigateToFixPage();
    }
  }

  Widget _buildWalletView(BuildContext context) {
    var activatedWalletVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).activatedWallet;
    if (activatedWalletVo != null) {
      if (!_isSafeLockUnlock)
        return WalletSafeLock(
          onUnlock: () {
            _isSafeLockUnlock = true;
            if (mounted) setState(() {});
          },
        );

      return LoadDataContainer(
        bloc: loadDataBloc,
        enablePullUp: false,
        showLoadingWidget: false,
        onLoadData: () {
          listLoadingData();
        },
        onRefresh: () async {
          listLoadingData();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            _headerWidget(activatedWalletVo),
            _coinListWidget(activatedWalletVo)
          ],
        ),
      );
    } else {
      return EmptyWalletViewV2(
        loadDataBloc: loadDataBloc,
      );
    }
  }

  _headerWidget(WalletVo activatedWalletVo) {
    return SliverToBoxAdapter(
      child: Container(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffEDC313), Color(0xffF7D33D)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
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
                if(!_hasBackupWallet)
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
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 30.0),
              child: Text(
                _isShowBalances
                    ? '${FormatUtil.formatPrice(activatedWalletVo.balance)}'
                    : '${activeQuotesSign?.sign ?? ''} *******',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: DefaultColors.color333,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(
                      "res/drawable/ic_wallet_account_list_send_v2.png",
                      width: 26,
                      height: 26,
                    ),
                    Text(
                      "发送",
                      style: TextStyles.textC333S14bold,
                    ),
                  ],
                ),
                SizedBox(
                  width: 51,
                ),
                Column(
                  children: [
                    Image.asset(
                      "res/drawable/ic_wallet_account_list_receiver_v2.png",
                      width: 26,
                      height: 26,
                    ),
                    Text(
                      "接收",
                      style: TextStyles.textC333S14bold,
                    ),
                  ],
                ),
                SizedBox(
                  width: 51,
                ),
                Column(
                  children: [
                    Image.asset(
                      "res/drawable/ic_wallet_account_list_exchange_v2.png",
                      width: 26,
                      height: 26,
                    ),
                    Text(
                      "交易",
                      style: TextStyles.textC333S14bold,
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _coinListWidget(WalletVo activatedWalletVo) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      var coinVo = activatedWalletVo.coins[index];
      var hasPrice = true;
      return InkWell(
          onTap: () {
            var coinVo = activatedWalletVo.coins[index];
            var coinVoJsonStr =
                FluroConvertUtils.object2string(coinVo.toJson());
            Application.router.navigateTo(context,
                Routes.wallet_account_detail + '?coinVo=$coinVoJsonStr');
          },
          child: _buildAccountItem(context, coinVo, hasPrice: hasPrice));
    }, childCount: activatedWalletVo.coins.length));
  }

  Widget _buildAccountItem(BuildContext context, CoinVo coin,
      {bool hasPrice = true}) {
    var symbol = coin.symbol;
    var symbolQuote =
        WalletInheritedModel.of(context).activatedQuoteVoAndSign(symbol);
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
          ? "${symbolQuote?.sign?.sign ?? ''} ${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(coin) * (symbolQuote?.quoteVo?.price ?? 0))}"
          : '${symbolQuote?.sign?.sign ?? ''} *****';
    }

    return Padding(
      padding:
          const EdgeInsets.only(left: 22.0, right: 22, top: 16, bottom: 16),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            child: ImageUtil.getCoinImage(coin.logo),
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
    );
  }

  Future listLoadingData() async {
    _checkDexAccount();
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletPageEvent());

    if (mounted) {
      loadDataBloc.add(RefreshSuccessEvent());
    }
  }

  Widget hynQuotesView() {
    //hyn quote
    ActiveQuoteVoAndSign hynQuoteSign =
        WalletInheritedModel.of(context).activatedQuoteVoAndSign('HYN');
    return Container(
      padding: EdgeInsets.all(8),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    'res/drawable/ic_hyperion.png',
                    width: 20,
                    height: 20,
                  ),
                ),
                Text(
                  S.of(context).hyn_price,
                  style: TextStyle(color: Color(0xFF6D6D6D), fontSize: 14),
                ),
                //Container(width: 100,),
                Spacer(),
                //quote
                Text(
                  '${hynQuoteSign != null ? '${FormatUtil.formatPrice(hynQuoteSign.quoteVo.price)} ${hynQuoteSign.sign.quote}' : '--'}',
                  style: TextStyle(
                      color: HexColor('#333333'),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
          ),
          Image.asset('res/drawable/bg_banner_hyn_burn.png')
        ],
      ),
    );
  }

  Widget _authorizedView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Spacer(),
          Image.asset(
            'res/drawable/logo_manwu.png',
            width: 23,
            height: 23,
            color: Colors.grey[500],
          ),
          SizedBox(
            width: 4.0,
          ),
          Text(
            S.of(context).safety_certification_by_organizations,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.0,
            ),
          ),
          Spacer()
        ],
      ),
    );
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
    loadDataBloc.close();
    super.dispose();
  }
}
