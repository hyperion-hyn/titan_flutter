import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/pages/market/entity/market_item_entity.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'dart:math' as math;

import 'package:titan/src/utils/format_util.dart';

class ExchangeQuoteListPage extends StatefulWidget {
  ExchangeQuoteListPage();

  @override
  State<StatefulWidget> createState() {
    return _ExchangeQuoteListPageState();
  }
}

class _ExchangeQuoteListPageState extends State<ExchangeQuoteListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var quoteList = MarketInheritedModel.of(
      context,
      aspect: SocketAspect.marketItemList,
    ).getFilterMarketItemList();
    return CustomScrollView(
      semanticChildCount: quoteList.length,
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final int itemIndex = index ~/ 2;
              if (index.isEven) {
                return _quoteListItem(quoteList[itemIndex]);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(height: 1),
              );
            },
            semanticIndexCallback: (Widget widget, int localIndex) {
              if (localIndex.isEven) {
                return localIndex ~/ 2;
              }
              return null;
            },
            childCount: math.max(0, quoteList.length * 2 - 1),
          ),
        ),
      ],
    );
  }

  _quoteListItem(MarketItemEntity marketItemEntity) {
    var base = marketItemEntity?.base;
    var quote = marketItemEntity?.quote;

    // price
    var _latestPrice = '--';
    var _latestPercentBgColor = HexColor('#FF53AE86');

    try {
      var _latestClose = Decimal.tryParse('${marketItemEntity.kLineEntity?.close}');

      if (_latestClose != null) {
        _latestPrice = FormatUtil.truncateDecimalNum(_latestClose, 4);
      }
    } catch (e) {}

    return Column(
      children: <Widget>[
        InkWell(
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExchangeDetailPage(
                            exchangeType: ExchangeType.BUY,
                            base: marketItemEntity.base,
                            quote: marketItemEntity.quote,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      Spacer(),
                      Text(
                        _latestPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: _latestPercentBgColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
