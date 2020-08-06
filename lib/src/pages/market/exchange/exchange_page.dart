import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_bloc.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_state.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/click_oval_icon_button.dart';

import '../k_line/kline_detail_page.dart';
import 'bloc/bloc.dart';

class ExchangePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangePageState();
  }
}

class _ExchangePageState extends BaseState<ExchangePage> {
  var _selectedCoin = 'USDT';
  var _exchangeType = ExchangeType.SELL;
  ExchangeBloc _exchangeBloc = ExchangeBloc();
  List<MarketItemEntity> _marketItemList = List();

  @override
  void dispose() {

    super.dispose();
    _exchangeBloc.close();
  }

  @override
  void onCreated() {

    super.onCreated();

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
          listener: (context, state) {},
        ),
      ],
      child: BlocBuilder<ExchangeBloc, ExchangeState>(
        bloc: _exchangeBloc,
        builder: (context, state) {
          if (state is SwitchToAuthState) {
            return ExchangeAuthPage();
          } else if (state is SwitchToContentState) {
            return _contentView();
          }
          return _contentView();
        },
      ),
    );
  }

  _contentView() {
    return Column(
      children: <Widget>[
        _banner(),
        _account(),
        _exchange(),
        _divider(),
        _quotesView(),
        _authorizedView()
      ],
    );
  }

  _banner() {
    return Container(
      color: HexColor('#0F1FB9C7'),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 8,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  'res/drawable/ic_exchange_banner_msg.png',
                  height: 15,
                  width: 14,
                )),
            Expanded(
              child: Text(
                '由于网络拥堵，近期闪兑交易矿工费较高',
                style: TextStyle(
                  fontSize: 12,
                  color: HexColor('#FF333333'),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            )
          ],
        ),
      ),
    );
  }

  _exchange() {
    var _selectedCoinToHYN = "--";
    var _hynToSelectedCoin = FormatUtil.truncateDoubleNum(
      _getMarketItem(_selectedCoin)?.kLineEntity?.close,
      4,
    );
    if (_hynToSelectedCoin != null && _hynToSelectedCoin != "null") {
      //print("_hynToSelectedCoin:$_hynToSelectedCoin, ${_hynToSelectedCoin == "null"}");
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
                  _exchangeItem(_exchangeType == ExchangeType.SELL),
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
                          _exchangeType = _exchangeType == ExchangeType.BUY
                              ? ExchangeType.SELL
                              : ExchangeType.BUY;
                        });
                      },
                    ),
                  ),
                  _exchangeItem(_exchangeType == ExchangeType.BUY),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '汇率',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              Text(
                _exchangeType == ExchangeType.SELL
                    ? '1HYN = $_hynToSelectedCoin $_selectedCoin'
                    : '1$_selectedCoin = $_selectedCoinToHYN HYN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              ClickOvalIconButton(
                '交易',
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
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      '24H 量 ${_getMarketItem(_selectedCoin)?.kLineEntity?.amount ?? '--'}',
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
                        '最新兑换1HYN  — $_hynToSelectedCoin $_selectedCoin',
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (ExchangeInheritedModel.of(context).exchangeModel.activeAccount !=
              null) {
            Application.router.navigateTo(
                context,
                Routes.exchange_assets_page +
                    '?entryRouteName=${Uri.encodeComponent(Routes.exchange_assets_page)}');
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ExchangeAuthPage()));
          }
        },
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
                        )
                      : Image.asset(
                          'res/drawable/ic_exchange_account_usd.png',
                          width: 18,
                          height: 18,
                        ),
            ),
            Text(
              '交易账户',
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
    );
  }

  _assetView() {
    var _totalByEth = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        ?.assetList
        ?.getTotalEth();
    var _ethQuotePrice = QuotesInheritedModel.of(context)
        .activatedQuoteVoAndSign('ETH')
        ?.quoteVo
        ?.price;
    if (ExchangeInheritedModel.of(context).exchangeModel.activeAccount !=
        null) {
      var _ethTotalQuotePrice = _ethQuotePrice != null && _totalByEth != null
          ? FormatUtil.truncateDecimalNum(
              // ignore: null_aware_before_operator
              _totalByEth * Decimal.parse(_ethQuotePrice?.toString()),
              4,
            )
          : '--';
      return Text.rich(
        TextSpan(children: [
          TextSpan(
              text: ExchangeInheritedModel.of(context)
                      .exchangeModel
                      .isShowBalances
                  ? _ethTotalQuotePrice
                  : '*****',
              style: TextStyle(
                fontSize: 14,
              )),
          TextSpan(
            text:
                ' (${QuotesInheritedModel.of(context).activatedQuoteVoAndSign('USDT')?.sign?.quote ?? ''})',
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
        '未登录',
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
                  if (_exchangeType == ExchangeType.BUY) Spacer(),
                  _coinItem(
                    'HYN',
                    SupportedTokens.HYN.logo,
                    false,
                  ),
                  if (_exchangeType == ExchangeType.BUY) Spacer(),
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
    availableCoinItemList.add(
      DropdownMenuItem(
        value: 'ETH',
        child: _coinItem(
          'ETH',
          SupportedTokens.ETHEREUM.logo,
          false,
        ),
      ),
    );

    return Row(
      children: <Widget>[
        if (_exchangeType == ExchangeType.SELL) Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            onChanged: (value) {
              setState(() {
                _selectedCoin = value;
              });
            },
            value: _selectedCoin,
            items: availableCoinItemList,
          ),
        ),
        if (_exchangeType == ExchangeType.BUY) Spacer(),
      ],
    );
  }

  _quotesView() {
    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '名称',
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
                          '最新价',
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
                            '跌涨幅',
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
          ),
          _quotesItemList()
        ],
      ),
    );
  }

  _quotesItemList() {
    return Expanded(
      child: ListView.builder(
          itemCount: _marketItemList.length,
          itemBuilder: (context, index) {
            return _marketItem(_marketItemList[index]);
          }),
    );
  }

  _marketItem(MarketItemEntity marketItemEntity) {
    var _selectedQuote =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign(
      marketItemEntity.symbolName,
    );
    var _latestPrice = FormatUtil.truncateDecimalNum(
      Decimal.parse(MarketInheritedModel.of(context).getRealTimePrice(
        marketItemEntity.symbol,
      )),
      4,
    );
    var _latestQuotePrice = _selectedQuote == null
        ? '--'
        : FormatUtil.truncateDoubleNum(
            double.parse(_latestPrice) * _selectedQuote?.quoteVo?.price,
            4,
          );
    double _latestPercent =
        MarketInheritedModel.of(context).getRealTimePricePercent(
      marketItemEntity.symbol,
    );

    return Column(
      children: <Widget>[
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KLineDetailPage(
                            symbol: marketItemEntity.symbol,
                            symbolName: marketItemEntity.symbolName,
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
                                  text: '/${marketItemEntity.symbolName}',
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
                              '24H量 ${marketItemEntity.kLineEntity.amount}',
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
                                  '$_latestPrice',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${_selectedQuote?.sign?.sign ?? ''} $_latestQuotePrice',
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
                                color: _latestPercent == 0
                                    ? HexColor('#FF999999')
                                    : _latestPercent > 0
                                        ? HexColor('#FF53AE86')
                                        : HexColor('#FFCC5858'),
                              ),
                              child: Center(
                                child: Text(
                                  '${(_latestPercent) > 0 ? '+' : ''}${FormatUtil.truncateDoubleNum(
                                    _latestPercent * 100.0,
                                    2,
                                  )}%',
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

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF2F2F2'),
    );
  }
}
