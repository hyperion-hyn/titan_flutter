import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/app_lock/app_lock_component.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/entity/exchange_coin_list.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_bloc.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_state.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/exchange/exchange_banner.dart';
import 'package:titan/src/pages/market/exchange/exchange_quote_list_page.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_page.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/loading_button/click_oval_icon_button.dart';

import '../k_line/kline_detail_page.dart';
import 'bloc/bloc.dart';
import 'dart:convert';
import 'dart:math' as math;

class ExchangePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangePageState();
  }
}

class _ExchangePageState extends BaseState<ExchangePage> with AutomaticKeepAliveClientMixin {
  ExchangeBloc _exchangeBloc = ExchangeBloc();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _exchangeBloc.close();
    _loadDataBloc.close();
  }

  @override
  void onCreated() {
    super.onCreated();

    ///check account
    BlocProvider.of<ExchangeCmpBloc>(context).add(CheckAccountEvent());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ExchangeBloc, ExchangeState>(
          bloc: _exchangeBloc,
          listener: (context, state) {},
        ),
        BlocListener<SocketBloc, SocketState>(
          listener: (context, state) async {
            if (state is UpdateExchangeCoinListState) {}
          },
        ),
      ],
      child: BlocBuilder<ExchangeBloc, ExchangeState>(
        bloc: _exchangeBloc,
        builder: (context, state) {
          return Container(
            color: Colors.white,
            child: LoadDataContainer(
              bloc: _loadDataBloc,
              enablePullUp: false,
              onLoadData: () async {
                _loadDataBloc.add(RefreshSuccessEvent());
                _refreshController.refreshCompleted();
              },
              onRefresh: () async {
                ///update assets if logged in
                if (ExchangeInheritedModel.of(context).exchangeModel.hasActiveAccount()) {
                  BlocProvider.of<ExchangeCmpBloc>(context).add(UpdateAssetsEvent());
                }

                ///update symbol list
                BlocProvider.of<SocketBloc>(context).add(MarketSymbolEvent());

                _loadDataBloc.add(RefreshSuccessEvent());
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: ExchangeBannerWidget(),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 12,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _account(),
                  ),
                  SliverToBoxAdapter(
                    child: _quotesTabs(),
                  ),
                  _quoteList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _account() {
    var hasExchangeAuth = ExchangeInheritedModel.of(context).exchangeModel.hasActiveAccount();
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Container(
        decoration: new BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xffE7C01A), Color(0xffF7D33D)],
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: InkWell(
                onTap: () async {
                  if (await _checkShowConfirmPolicy()) {
                    bool result = await UiUtil.showConfirmPolicyDialog(context, PolicyType.DEX);
                    if (!result) return;
                  }

                  if (hasExchangeAuth) {
                    Application.router.navigateTo(
                        context,
                        Routes.exchange_assets_page +
                            '?entryRouteName=${Uri.encodeComponent(Routes.exchange_assets_page)}');
                  } else {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Row(children: [_asset()]),
                    SizedBox(height: 4.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 4),
                        Text(
                          hasExchangeAuth
                              ? S.of(context).exchange_account
                              : S.of(context).exchange_logged_out,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            _exchange(),
          ],
        ),
      ),
    );
  }

  _exchange() {
    return Container(
      color: HexColor('#000000').withOpacity(0.03),
      child: InkWell(
        onTap: () {
          _showQuoteListDialog();
        },
        child: Padding(
          child: Row(
            children: [
              SizedBox(width: 8),
              Image.asset(
                'res/drawable/icon_btn_exchange.png',
                width: 16,
                height: 16,
              ),
              SizedBox(width: 6),
              Text(
                '兑换',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
      ),
    );
  }

  _asset() {
    var _fiatSign = WalletInheritedModel.of(context)?.tokenLegalPrice('USDT')?.legal?.sign ?? '';
    var _isShowBalance = ExchangeInheritedModel.of(context).exchangeModel?.isShowBalances ?? true;
    var _hasExchangeAuth = ExchangeInheritedModel.of(context).exchangeModel?.hasActiveAccount();

    var _usdtTotalQuotePrice = '-----';

    if (_hasExchangeAuth) {
      try {
        var _totalByUSDT = ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            ?.assetList
            ?.getTotalUsdt();

        var _coinQuotePrice = WalletInheritedModel.of(context).tokenLegalPrice('USDT')?.price;

        _usdtTotalQuotePrice =
            FormatUtil.truncateDecimalNum(_totalByUSDT * Decimal.parse('$_coinQuotePrice'), 4);
      } catch (e) {}
    }

    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: '$_fiatSign  ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextSpan(
          text: _isShowBalance ? _usdtTotalQuotePrice : '*****',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ]),
      textAlign: TextAlign.center,
    );
  }

  _quoteList() {
    var quoteList = MarketInheritedModel.of(
      context,
      aspect: SocketAspect.marketItemList,
    ).getFilterMarketItemList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _quoteItem(quoteList[index]);
        },
        childCount: quoteList.length,
      ),
    );
  }

  _quotesTabs() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              S.of(context).exchange_name,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 80,
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    S.of(context).exchange_latest_quote,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      S.of(context).exchange_change_percentage,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _quoteItem(MarketItemEntity marketItemEntity) {
    var base = marketItemEntity?.base;
    var quote = marketItemEntity?.quote;

    var _vol24h = '--';

    try {
      var _latestVol = Decimal.tryParse('${marketItemEntity.kLineEntity?.vol}');
      if (_latestVol != null) {
        _vol24h = FormatUtil.truncateDecimalNum(_latestVol, 2) ?? '--';
      }
    } catch (e) {}

    // 24hour
    var _volStr = '${S.of(context).exchange_24h_vol} $_vol24h';

    // price
    var _latestPrice = '--';
    var _latestQuotePriceStr = '--';
    var _latestPercentStr = '--';
    var _latestPercentBgColor = HexColor('#FF53AE86');

    try {
      var _latestClose = Decimal.tryParse('${marketItemEntity.kLineEntity?.close}');

      if (_latestClose != null) {
        _latestPrice = FormatUtil.truncateDecimalNum(_latestClose, 4);
      }

      var _latestPercent = MarketInheritedModel.of(
        context,
        aspect: SocketAspect.marketItemList,
      ).getRealTimePricePercent(
        marketItemEntity.symbol,
      );

      if (_latestPercent.isNaN || _latestPercent.isInfinite) {
        _latestPercentStr = '--%';
      } else {
        _latestPercentBgColor = _latestPercent < 0 ? HexColor('#FFCC5858') : HexColor('#FF53AE86');

        _latestPercentStr =
            '${(_latestPercent) > 0 ? '+' : ''}${FormatUtil.truncateDoubleNum(_latestPercent * 100.0, 2)}%';
      }

      var _quote = WalletInheritedModel.of(context).tokenLegalPrice(
        marketItemEntity?.base,
      );
      var _latestQuotePrice;
      var _quotePrice = Decimal.tryParse('${_quote?.price}');

      if (_latestClose != null && _quotePrice != null) {
        _latestQuotePrice = FormatUtil.truncateDecimalNum(
          _latestClose * _quotePrice,
          4,
        );
      }

      _latestQuotePriceStr = '${_quote?.legal?.sign ?? ''} ${_latestQuotePrice ?? '--'}';
    } catch (e) {}

    return Column(
      children: <Widget>[
        InkWell(
            onTap: () async {
              if (await _checkShowConfirmPolicy()) {
                bool result = await UiUtil.showConfirmPolicyDialog(context, PolicyType.DEX);
                if (!result) return;
              }

              var prefs = await SharedPreferences.getInstance();
              int index = prefs.getInt(PrefsKey.PERIOD_CURRENT_INDEX);
              var periodCurrentIndex = 0;
              if (index != null && index < 4) {
                periodCurrentIndex = index;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KLineDetailPage(
                            symbol: marketItemEntity.symbol,
                            isPop: false,
                            periodCurrentIndex: periodCurrentIndex,
                            base: marketItemEntity.base,
                            quote: marketItemEntity.quote,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: quote,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 16,
                                  )),
                              TextSpan(
                                  text: '/',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  )),
                              TextSpan(
                                  text: base,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  )),
                            ])),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              _volStr ?? '-',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _latestPrice,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  _latestQuotePriceStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            Container(
                              width: 70,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: _latestPercentBgColor,
                              ),
                              child: Center(
                                child: Text(
                                  _latestPercentStr,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 1,
          ),
        )
      ],
    );
  }

  _showQuoteListDialog() async {
    if (await _checkShowConfirmPolicy()) {
      bool result = await UiUtil.showConfirmPolicyDialog(context, PolicyType.DEX);
      if (!result) return;
    }
    UiUtil.showBottomDialogView(
      context,
      dialogHeight: MediaQuery.of(context).size.height - 80,
      isScrollControlled: true,
      customWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text(S.of(context).select_quote, style: TextStyles.textC333S14bold),
            ),
          ),
          Expanded(
            child: ExchangeQuoteListPage(),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkShowConfirmPolicy() async {
    var isConfirmDexPolicy = await AppCache.getValue(
      PrefsKey.IS_CONFIRM_DEX_POLICY,
    );
    return isConfirmDexPolicy == null || !isConfirmDexPolicy;
  }
}
