import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
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
        baseTitle: S.of(context).burning_detail,
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
                child: Text(S.of(context).atlas_automatically_completed_burning_plan(' ${widget._burnHistory.epoch} ')),
              ),
            ],
          ),
          _optionItem(
            S.of(context).burning_era,
            '${widget._burnHistory.epoch}',
          ),
          _optionItem(
            S.of(context).block_height,
            '${widget._burnHistory.block}',
          ),
          _optionItem(
            S.of(context).burning_amount,
            '$_burnTokenAmountStr',
          ),
          _optionItem(
            S.of(context).hyn_price_num,
            '${quotesSign.sign} ${hynQuote?.price ?? '--'}',
          ),
          _optionItem(
            S.of(context).value_equivalent_to,
            '${quotesSign.sign} $_burnTokenPriceStr',
          ),
          _optionItem(
            S.of(context).of_total_supply,
            '$_burnRate %',
          ),
          _optionItem(
            S.of(context).total_supply_after_combustion,
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
                S.of(context).view_bill,
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(S.of(context).thanks_for_your_support),
          SizedBox(
            height: 8,
          ),
          Text(S.of(context).hyperion_team),
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
                content ?? S.of(context).nothing,
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
          quoteItem.quote == quotesSign?.quote) {
        hynQuote = quoteItem;
      }
    }
    setState(() {});
  }
}
