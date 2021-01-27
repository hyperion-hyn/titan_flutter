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
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/market/transfer/exchange_transfer_page.dart';
import 'package:titan/src/pages/policy/policy_confirm_page.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/loading_button/click_oval_icon_button.dart';

import '../k_line/kline_detail_page.dart';
import 'bloc/bloc.dart';
import 'dart:convert';

class ExchangePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangePageState();
  }
}

class _ExchangePageState extends BaseState<ExchangePage> with AutomaticKeepAliveClientMixin {
  var _selectedBase = '';
  var _selectedQuote = '';
  var _exchangeType = ExchangeType.BUY;

  ExchangeBloc _exchangeBloc = ExchangeBloc();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

  ExchangeCoinList _exchangeCoinList;

  List<DropdownMenuItem> baseCoinItemLIst = List();
  List<DropdownMenuItem> quoteCoinItemLIst = List();

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

    _updateQuotes();

    _setUpExchangeCoinList();
  }

  _showConfirmDexPolicy() {
    UiUtil.showAlertView(
      context,
      title: S.of(context).important_hint,
      actions: [
        ClickOvalButton(
          S.of(context).check,
          () async {
            Navigator.pop(context);
            UiUtil.showConfirmPolicyDialog(context, PolicyType.DEX);
          },
          width: 160,
          height: 38,
          fontSize: 16,
        ),
      ],
      content: S.of(context).please_read_and_agress_dex_policy,
      barrierDismissible: false,
    );
  }

  _updateQuotes() async {
    // var quoteSignStr = await AppCache.getValue<String>(PrefsKey.SETTING_QUOTE_SIGN);
    // QuotesSign quotesSign = quoteSignStr != null
    //     ? QuotesSign.fromJson(json.decode(quoteSignStr))
    //     : SupportedQuoteSigns.defaultQuotesSign;
    //
    // BlocProvider.of<WalletCmpBloc>(context).add(UpdateQuotesSignEvent(sign: quotesSign));
    // BlocProvider.of<WalletCmpBloc>(context).add(UpdateQuotesEvent(isForceUpdate: true));
  }

  _setUpExchangeCoinList() async {
    var list = MarketInheritedModel.of(
      context,
      aspect: SocketAspect.marketItemList,
    ).exchangeCoinList;

    if (list != null) {
      _exchangeCoinList = list;
      await _resetCoinList(true);
    }
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
            if (state is UpdateExchangeCoinListState) {
              await _setUpExchangeCoinList();
              if (mounted) setState(() {});
            }
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

                // BlocProvider.of<SocketBloc>(context).add(UpdateExchangeCoinListEvent());

                _loadDataBloc.add(RefreshSuccessEvent());
                _refreshController.refreshCompleted();
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: ExchangeBannerWidget(),
                  ),
                  SliverToBoxAdapter(
                    child: _account(),
                  ),
                  SliverToBoxAdapter(
                    child: _exchange(),
                  ),
                  SliverToBoxAdapter(
                    child: _divider(),
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

  _exchange() {
    var switchButton = Expanded(
      flex: 1,
      child: IconButton(
        icon: Image.asset(
          'res/drawable/market_exchange_btn_icon.png',
          width: 20,
          height: 18,
        ),
        onPressed: () {
          setState(() {
            _exchangeType =
                (_exchangeType == ExchangeType.BUY ? ExchangeType.SELL : ExchangeType.BUY);
          });
        },
      ),
    );
    var baseDropDown = Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _baseDropDownList(),
      ),
    );

    var quoteDropDown = Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _quoteDropDownList(),
      ),
    );
    List<Widget> widgetList = [];
    if (_exchangeType == ExchangeType.BUY) {
      widgetList = [baseDropDown, switchButton, quoteDropDown];
    } else {
      widgetList = [quoteDropDown, switchButton, baseDropDown];
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            borderRadius: BorderRadius.circular(
              8.0,
            ),
            elevation: 3.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: widgetList.isNotEmpty ? widgetList : [SizedBox()],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 8.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              ClickOvalIconButton(
                S.of(context).exchange_trade,
                () async {
                  if (await _checkShowConfirmPolicy()) {
                    _showConfirmDexPolicy();
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExchangeDetailPage(
                                  exchangeType: _exchangeType,
                                  base: _selectedBase,
                                  quote: _selectedQuote,
                                )));
                  }
                },
                width: 88,
                height: 38,
                radius: 6,
                fontSize: 14,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              )
            ],
          ),
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  _account() {
    var quote = WalletInheritedModel.of(context).tokenLegalPrice('USDT')?.legal?.legal;
    return InkWell(
      onTap: () async {
        if (await _checkShowConfirmPolicy()) {
          _showConfirmDexPolicy();
        } else {
          if (ExchangeInheritedModel.of(context).exchangeModel.hasActiveAccount()) {
            Application.router.navigateTo(
                context,
                Routes.exchange_assets_page +
                    '?entryRouteName=${Uri.encodeComponent(Routes.exchange_assets_page)}');
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
          }
        }
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 6.0,
                ),
                child: quote == null
                    ? Image.asset(
                        'res/drawable/ic_exchange_account_cny.png',
                        width: 20,
                        height: 20,
                        color: Theme.of(context).primaryColor,
                      )
                    : WalletInheritedModel.of(context)
                                .tokenLegalPrice('USDT')
                                ?.legal
                                ?.legal ==
                            'CNY'
                        ? Image.asset(
                            'res/drawable/ic_exchange_account_cny.png',
                            width: 18,
                            height: 18,
                            color: Theme.of(context).primaryColor,
                          )
                        : Image.asset(
                            'res/drawable/ic_exchange_account_usd.png',
                            width: 18,
                            height: 18,
                            color: Theme.of(context).primaryColor,
                          ),
              ),
              Text(
                S.of(context).exchange_account,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              _assetView(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkShowConfirmPolicy() async {
    var isConfirmDexPolicy = await AppCache.getValue(
      PrefsKey.IS_CONFIRM_DEX_POLICY,
    );
    return isConfirmDexPolicy == null || !isConfirmDexPolicy;
  }

  _assetView() {
    var _usdtTotalQuotePrice = '--';

    try {
      var _totalByUSDT =
          ExchangeInheritedModel.of(context).exchangeModel.activeAccount?.assetList?.getTotalUsdt();

      var _coinQuotePrice =
          WalletInheritedModel.of(context).tokenLegalPrice('USDT')?.price;

      _usdtTotalQuotePrice = FormatUtil.truncateDecimalNum(
        _totalByUSDT *
            Decimal.parse(
              '$_coinQuotePrice',
            ),
        4,
      );
    } catch (e) {}

    var _quoteSymbol =
        WalletInheritedModel.of(context).tokenLegalPrice('USDT')?.legal?.legal;
    var _isShowBalance = ExchangeInheritedModel.of(context).exchangeModel?.isShowBalances ?? true;
    var _isExchangeAccountLoggin =
        ExchangeInheritedModel.of(context).exchangeModel?.hasActiveAccount() ?? false;

    if (AppLockInheritedModel.of(context).isLockActive) {
      return Text('请先解锁钱包');
    }
    if (_isExchangeAccountLoggin) {
      return Text.rich(
        TextSpan(children: [
          TextSpan(
              text: _isShowBalance ? _usdtTotalQuotePrice : '*****',
              style: TextStyle(
                fontSize: 12,
              )),
          TextSpan(
            text: ' (${_quoteSymbol ?? ''})',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          )
        ]),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        S.of(context).exchange_logged_out,
        style: TextStyle(
          color: HexColor('#FF1F81FF'),
        ),
      );
    }
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

  _coinItem(
    String name,
    String logoPath,
    bool isOnlinePath,
  ) {
    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF9B9B9B), width: 0),
            shape: BoxShape.circle,
          ),
          child: isOnlinePath
              ? FadeInImage.assetNetwork(
                  placeholder: 'res/drawable/img_placeholder_circle.png',
                  image: logoPath,
                  fit: BoxFit.cover,
                )
              : Image.asset(logoPath),
        ),
        SizedBox(
          width: 8.0,
        ),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        )
      ],
    );
  }

  _resetCoinList(bool isApiRefresh) {
    baseCoinItemLIst.clear();
    quoteCoinItemLIst.clear();
    _exchangeCoinList?.activeExchangeMap?.forEach((key, value) {
      baseCoinItemLIst.add(DropdownMenuItem(
        value: key,
        child: _coinItem(
          key,
          Tokens.getCoinIconPathBySymbol(key),
          false,
        ),
      ));
    });

    if (baseCoinItemLIst.first != null && isApiRefresh) {
      _selectedBase = baseCoinItemLIst.first.value;
    }

    _exchangeCoinList?.activeExchangeMap?.forEach((key, value) {
      if (key == _selectedBase) {
        value?.forEach((coin) {
          quoteCoinItemLIst.add(DropdownMenuItem(
            value: coin,
            child: _coinItem(
              coin,
              Tokens.getCoinIconPathBySymbol(coin),
              false,
            ),
          ));
        });
      }
    });

    if (quoteCoinItemLIst.first != null) {
      _selectedQuote = quoteCoinItemLIst.first.value;
    }
  }

  _baseDropDownList() {
    return Row(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton(
            onChanged: (value) async {
              _selectedBase = value;
              await _resetCoinList(false);
              setState(() {});
            },
            value: _selectedBase,
            items: baseCoinItemLIst,
          ),
        ),
      ],
    );
  }

  _quoteDropDownList() {
    return Row(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton(
            onChanged: (value) async {
              _selectedQuote = value;
              setState(() {});
            },
            value: _selectedQuote,
            items: quoteCoinItemLIst,
          ),
        )
      ],
    );
  }

  _quotesTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              S.of(context).exchange_name,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
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
                      fontSize: 14,
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
                        fontSize: 14,
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
                _showConfirmDexPolicy();
              } else {
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
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                              width: 80,
                              height: 39,
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

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF2F2F2'),
    );
  }
}
