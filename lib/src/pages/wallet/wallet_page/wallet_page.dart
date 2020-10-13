import 'dart:async';
import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/bloc/quotes_cmp_bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/transfer/exchange_abnormal_transfer_list_page.dart';
import 'package:titan/src/pages/wallet/api/bitcoin_api.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/auth_dialog/SetBioAuthDialog.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog.dart';

import 'view/wallet_empty_widget.dart';
import 'view/wallet_show_widget.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

class _WalletPageState extends BaseState<WalletPage>
    with RouteAware, AutomaticKeepAliveClientMixin {
  LoadDataBloc loadDataBloc = LoadDataBloc();

  final LocalAuthentication auth = LocalAuthentication();

  ExchangeApi _exchangeApi = ExchangeApi();

  bool _isExchangeAccountAbnormal = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    ///check dex account is abnormal
    _checkDexAccount();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didPopNext() async {
    callLater((_) {
      BlocProvider.of<WalletCmpBloc>(context)
          .add(UpdateActivatedWalletBalanceEvent());
    });
  }

  @override
  Future<void> onCreated() async {
    //update quotes
//    BlocProvider.of<QuotesCmpBloc>(context)
//        .add(UpdateQuotesEvent(isForceUpdate: true));
    //update all coin balance
//    BlocProvider.of<WalletCmpBloc>(context)
//        .add(UpdateActivatedWalletBalanceEvent());
    Future.delayed(Duration(milliseconds: 3000), () {
      _postWalletBalance();
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
          '${PrefsKey.EXCHANGE_ACCOUNT_ABNORMAL}${activatedWalletVo.wallet.getEthAccount().address}',
        ) ??
        false;

    setState(() {});

    ///get value from server
    try {
      ///
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

    var activatedWalletVo =
        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet)
            .activatedWallet;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
//      appBar: AppBar(
//        elevation: 0,
//        backgroundColor: Colors.white,
//        title: Center(
//          child: Text(
//            S.of(context).wallet,
//            style: TextStyle(
//              color: Colors.black,
//              fontSize: 18,
//            ),
//          ),
//        ),
//      ),
      body: Container(
        color: Colors.white,
        child: Column(
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
            _authorizedView(),
          ],
        ),
      ),
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
      ;
    }
  }

  Widget _buildWalletView(BuildContext context) {
    var activatedWalletVo =
        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet)
            .activatedWallet;
    if (activatedWalletVo != null) {
      return LoadDataContainer(
          bloc: loadDataBloc,
          enablePullUp: false,
          onLoadData: () {
            _checkDexAccount();
            listLoadingData();
          },
          onRefresh: () async {
            _checkDexAccount();
            listLoadingData();
          },
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ShowWalletView(
                activatedWalletVo,
                loadDataBloc,
              )));
    }

    return BlocListener<WalletCmpBloc, WalletCmpState>(
      listener: (ctx, state) {},
      child: BlocBuilder<WalletCmpBloc, WalletCmpState>(
        builder: (BuildContext context, WalletCmpState state) {
          switch (state.runtimeType) {
            case LoadingWalletState:
              return loadingView(context);
            default:
              return EmptyWalletView();
          }
        },
      ),
    );
  }

  Future listLoadingData() async {
    //update quotes
    var quoteSignStr =
        await AppCache.getValue<String>(PrefsKey.SETTING_QUOTE_SIGN);
    QuotesSign quotesSign = quoteSignStr != null
        ? QuotesSign.fromJson(json.decode(quoteSignStr))
        : SupportedQuoteSigns.defaultQuotesSign;
    BlocProvider.of<QuotesCmpBloc>(context)
        .add(UpdateQuotesSignEvent(sign: quotesSign));
    BlocProvider.of<QuotesCmpBloc>(context)
        .add(UpdateQuotesEvent(isForceUpdate: true));
    //update all coin balance
    BlocProvider.of<WalletCmpBloc>(context)
        .add(UpdateActivatedWalletBalanceEvent());

    await Future.delayed(Duration(milliseconds: 700));

    if (mounted) {
      loadDataBloc.add(RefreshSuccessEvent());
    }
  }

  Widget hynQuotesView() {
    //hyn quote
    ActiveQuoteVoAndSign hynQuoteSign =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign('HYN');
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
          )
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
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    loadDataBloc.close();
    super.dispose();
  }
}
