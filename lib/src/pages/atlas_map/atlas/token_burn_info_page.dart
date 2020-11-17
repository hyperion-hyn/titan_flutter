import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/coin_market_api.dart';
import 'package:titan/src/components/wallet/vo/symbol_quote_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/atlas/token_burn_detail_page.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_detail_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

class TokenBurnInfoPage extends StatefulWidget {
  final BurnHistory _burnHistory;

  TokenBurnInfoPage(this._burnHistory);

  @override
  State<StatefulWidget> createState() {
    return _TokenBurnInfoPageState();
  }
}

class _TokenBurnInfoPageState extends State<TokenBurnInfoPage> {
  CoinMarketApi _coinMarketApi = CoinMarketApi();

  SymbolQuoteVo hynQuote;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHynQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '燃烧详情',
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        child: SingleChildScrollView(
          child: _content(),
        ),
      ),
    );
  }

  _content() {
    var quotesSign = WalletInheritedModel.of(context).activeQuotesSign;
    var _burnRate = Decimal.parse(widget._burnHistory.burnRate ?? '0') *
        Decimal.fromInt(100);

    var _burnTokenAmountStr =
        FormatUtil.stringFormatCoinNum(widget._burnHistory.getTotalAmount());
    var _burnTokenPriceValue = Decimal.parse('${hynQuote?.price ?? 0}') *
        Decimal.parse(widget._burnHistory.getTotalAmount());
    var _burnTokenPriceStr =
        FormatUtil.stringFormatCoinNum(_burnTokenPriceValue.toString());
    var _hynSupplyAmountStr =
        FormatUtil.stringFormatCoinNum(widget._burnHistory.getHynSupply());
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(
                  'res/drawable/hyn.png',
                  width: 40,
                  height: 40,
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text('Atlas主链已经自动完成第${widget._burnHistory.epoch}纪元燃烧计划'),
              ),
            ],
          ),
          _optionItem(
            '燃烧纪元',
            '${widget._burnHistory.epoch}',
          ),
          _optionItem(
            '区块高度',
            '${widget._burnHistory.block}',
          ),
          _optionItem(
            '燃烧纪元',
            '${widget._burnHistory.epoch}',
          ),
          _optionItem(
            '燃烧量',
            '$_burnTokenAmountStr',
          ),
          _optionItem(
            'HYN价格',
            '${quotesSign.sign} ${hynQuote?.price ?? '--'}',
          ),
          _optionItem(
            '价值(相当于)',
            '${quotesSign.sign} $_burnTokenPriceStr',
          ),
          _optionItem(
            '占总供应量',
            '$_burnRate %',
          ),
          _optionItem(
            '燃烧后HYN总供应量',
            '$_hynSupplyAmountStr',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TokenBurnDetailPage(
                            widget._burnHistory,
                          )),
                );
              },
              child: Text(
                '查看',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text('感谢您的支持！'),
          SizedBox(
            height: 8,
          ),
          Text('海伯利安团队'),
        ],
      ),
    );
  }

  _optionItem(
    String name,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 130,
            child: Text(
              name,
              style: TextStyle(
                color: DefaultColors.color999,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                content ?? '无',
                style: TextStyle(
                  color: DefaultColors.color333,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getHynQuote() async {
    var quotes = await _coinMarketApi.quotes(widget._burnHistory.timestamp);
    var quotesSign = WalletInheritedModel.of(context).activeQuotesSign;
    for (var quoteItem in quotes) {
      if (quoteItem.symbol == SupportedTokens.HYN_Atlas.symbol &&
          quoteItem.quote == quotesSign.quote) {
        hynQuote = quoteItem;
      }
    }
    setState(() {});
  }
}
