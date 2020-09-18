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
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_bloc.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_state.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/exchange/exchange_banner.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
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

class _ExchangePageState extends BaseState<ExchangePage>
    with AutomaticKeepAliveClientMixin {
  var _selectedCoin = 'USDT';
  var _exchangeType = ExchangeType.BUY;

  ExchangeBloc _exchangeBloc = ExchangeBloc();
  List<MarketItemEntity> _marketItemList = List();
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

    _updateQuotes();

    ///
    _setupMarketItemList();
  }

  _updateQuotes() async {
    var quoteSignStr =
        await AppCache.getValue<String>(PrefsKey.SETTING_QUOTE_SIGN);
    QuotesSign quotesSign = quoteSignStr != null
        ? QuotesSign.fromJson(json.decode(quoteSignStr))
        : SupportedQuoteSigns.defaultQuotesSign;
    BlocProvider.of<QuotesCmpBloc>(context)
        .add(UpdateQuotesSignEvent(sign: quotesSign));
    BlocProvider.of<QuotesCmpBloc>(context)
        .add(UpdateQuotesEvent(isForceUpdate: true));
  }

  _setupMarketItemList() {
    if (MarketInheritedModel.of(context).marketItemList != null) {
      _marketItemList = MarketInheritedModel.of(context).marketItemList;
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
          listener: (context, state) {
            setState(() {
              _setupMarketItemList();
            });
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
                if (ExchangeInheritedModel.of(context)
                    .exchangeModel
                    .hasActiveAccount()) {
                  BlocProvider.of<ExchangeCmpBloc>(context)
                      .add(UpdateAssetsEvent());
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
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _marketItem(_marketItemList[index]);
                      },
                      childCount: _marketItemList.length,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _contentView() {
    return Column(
      children: <Widget>[
        _account(),
        _exchange(),
        _divider(),
        _quotesTabs(),
      ],
    );
  }

  _exchange() {
    var _selectedCoinToHYN = "--";
    var _hynToSelectedCoin = FormatUtil.truncateDoubleNum(
      _getMarketItem(_selectedCoin)?.kLineEntity?.close,
      4,
    );
    if (_hynToSelectedCoin != null &&
        _hynToSelectedCoin != "null" &&
        double.parse(_hynToSelectedCoin) > 0) {
      _selectedCoinToHYN = FormatUtil.truncateDecimalNum(
            Decimal.fromInt(1) /
                (Decimal.parse(
                  _hynToSelectedCoin.toString(),
                )),
            4,
          ) ??
          '--';
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
                children: <Widget>[
                  _exchangeItem(_exchangeType == ExchangeType.BUY),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Image.asset(
                        'res/drawable/market_exchange_btn_icon.png',
                        width: 20,
                        height: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _exchangeType = (_exchangeType == ExchangeType.BUY
                              ? ExchangeType.SELL
                              : ExchangeType.BUY);
                        });
                      },
                    ),
                  ),
                  _exchangeItem(_exchangeType == ExchangeType.SELL),
                ],
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
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExchangeDetailPage(
                              selectedCoin: _selectedCoin,
                              exchangeType: _exchangeType)));
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: HexColor('#FFF2F2F2'),
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${S.of(context).exchange_24h_amount} ${FormatUtil.truncateDoubleNum(_getMarketItem(_selectedCoin)?.kLineEntity?.amount, 2) ?? '--'}',
                      style: TextStyle(
                        color: HexColor('#FF999999'),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${S.of(context).exchange_latest_quote} ${_exchangeType == ExchangeType.BUY ? '1HYN = $_hynToSelectedCoin $_selectedCoin' : '1$_selectedCoin = $_selectedCoinToHYN HYN'}',
                        style: TextStyle(
                          color: HexColor('#FF999999'),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  _account() {
    var quote = QuotesInheritedModel.of(context)
        .activatedQuoteVoAndSign('USDT')
        ?.sign
        ?.quote;
    return InkWell(
      onTap: () {
        if (ExchangeInheritedModel.of(context)
            .exchangeModel
            .hasActiveAccount()) {
          Application.router.navigateTo(
              context,
              Routes.exchange_assets_page +
                  '?entryRouteName=${Uri.encodeComponent(Routes.exchange_assets_page)}');
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
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
                    : QuotesInheritedModel.of(context)
                                .activatedQuoteVoAndSign('USDT')
                                .sign
                                .quote ==
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

  _assetView() {
    var _totalByUsdt = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        ?.assetList
        ?.getTotalUsdt();
    var _coinQuotePrice = QuotesInheritedModel.of(context)
        .activatedQuoteVoAndSign('USDT')
        ?.quoteVo
        ?.price;
    var _quoteSymbol = QuotesInheritedModel.of(context)
        .activatedQuoteVoAndSign('USDT')
        ?.sign
        ?.quote;
    if (ExchangeInheritedModel.of(context).exchangeModel.activeAccount !=
        null) {
      var _usdtTotalQuotePrice = _coinQuotePrice != null && _totalByUsdt != null
          ? FormatUtil.truncateDecimalNum(
              // ignore: null_aware_before_operator
              _totalByUsdt * Decimal.parse(_coinQuotePrice?.toString()),
              4,
            )
          : '--';
      return Text.rich(
        TextSpan(children: [
          TextSpan(
              text: ExchangeInheritedModel.of(context)
                      .exchangeModel
                      .isShowBalances
                  ? _usdtTotalQuotePrice
                  : '*****',
              style: TextStyle(
                fontSize: 12,
              )),
          TextSpan(
            text: ' ${_quoteSymbol != null ? '($_quoteSymbol)' : ''}',
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

  _exchangeItem(bool isHynCoin) {
    return isHynCoin
        ? Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  if (_exchangeType == ExchangeType.SELL) Spacer(),
                  _coinItem(
                    'HYN',
                    SupportedTokens.HYN.logo,
                    false,
                  ),
                  if (_exchangeType == ExchangeType.SELL) Spacer(),
                ],
              ),
            ),
          )
        : Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _coinListDropdownBtn(),
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

  _coinListDropdownBtn() {
    List<DropdownMenuItem> availableCoinItemList = List();
    availableCoinItemList.add(
      DropdownMenuItem(
        value: 'USDT',
        child: _coinItem(
          'USDT',
          SupportedTokens.USDT_ERC20.logo,
          false,
        ),
      ),
    );
//    availableCoinItemList.add(
//      DropdownMenuItem(
//        value: 'ETH',
//        child: _coinItem(
//          'ETH',
//          SupportedTokens.ETHEREUM.logo,
//          false,
//        ),
//      ),
//    );

    return Row(
      children: <Widget>[
        if (_exchangeType == ExchangeType.BUY) Spacer(),
        _coinItem(
          'USDT',
          SupportedTokens.USDT_ERC20.logo,
          false,
        ),
        //if (_exchangeType == ExchangeType.SELL) Spacer(),
        Spacer()
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

  _marketItem(MarketItemEntity marketItemEntity) {
    // symbol
    var _symbolName = '/${marketItemEntity.symbolName}';

    // 24hour
    var _amount24Hour =
        '${S.of(context).exchange_24h_amount} ${FormatUtil.truncateDoubleNum(
      marketItemEntity.kLineEntity?.amount,
      2,
    )}';

    // price
    var _latestPrice = marketItemEntity.kLineEntity != null
        ? FormatUtil.truncateDecimalNum(
              Decimal.parse(
                  marketItemEntity.kLineEntity?.close.toString() ?? '0'),
              4,
            ) ??
            '-'
        : '-';
    var _latestPriceString = '$_latestPrice';

    var _selectedQuote =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign(
      marketItemEntity.symbolName,
    );
    var _latestQuotePrice = _selectedQuote == null
        ? '--'
        : FormatUtil.truncateDoubleNum(
            double.parse(_latestPrice) * _selectedQuote?.quoteVo?.price,
            4,
          );
    var _latestRmbPriceString =
        '${_selectedQuote?.sign?.sign ?? ''} $_latestQuotePrice';

    // _latestPercent
    double _latestPercent =
        MarketInheritedModel.of(context).getRealTimePricePercent(
      marketItemEntity.symbol,
    );
    var _latestPercentBgColor = _latestPercent == 0
        ? HexColor('#FF999999')
        : _latestPercent > 0 ? HexColor('#FF53AE86') : HexColor('#FFCC5858');
    var _latestPercentString =
        '${(_latestPercent) > 0 ? '+' : ''}${FormatUtil.truncateDoubleNum(
      _latestPercent * 100.0,
      2,
    )}%';

    //print("[marketItemEntity] symbol:${marketItemEntity.symbolName}, amount:${marketItemEntity.kLineEntity.amount}");
    return Column(
      children: <Widget>[
        InkWell(
            onTap: () async {
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
                            symbolName: marketItemEntity.symbolName,
                            isPop: false,
                            periodCurrentIndex: periodCurrentIndex,
                          )));
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                                  text: 'HYN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 16,
                                  )),
                              TextSpan(
                                  text: _symbolName,
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
                              _amount24Hour ?? '-',
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
                                  _latestPriceString ?? '--',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  _latestRmbPriceString,
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
                                  _latestPercentString,
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

  MarketItemEntity _getMarketItem(String coinType) {
    var result;
    _marketItemList.forEach((element) {
      if (element.symbolName == coinType) {
        result = element;
      }
    });
    return result;
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF2F2F2'),
    );
  }
}
