import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';

class ShowWalletView extends StatelessWidget {
  final WalletVo walletVo;
  LoadDataBloc loadDataBloc;

  ShowWalletView(this.walletVo, this.loadDataBloc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 10,
                child: Container(
                  padding:
                      EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 16),
                  child: Row(
                    children: <Widget>[
                      //balance
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${QuotesInheritedModel.of(context, aspect: QuotesAspect.quote).activeQuotesSign?.quote ?? ''}",
                            style: TextStyle(
                                color: Color(0xFF9B9B9B), fontSize: 16),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                QuotesInheritedModel.of(context,
                                            aspect: QuotesAspect.quote)
                                        .activeQuotesSign
                                        ?.sign ??
                                    '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "${WalletInheritedModel.formatPrice(walletVo.balance)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Application.router.navigateTo(
                              context,
                              Routes.wallet_manager +
                                  '?entryRouteName=${Uri.encodeComponent(Routes.root)}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "${walletVo.wallet.keystore.name}",
                                style: TextStyle(color: Color(0xFF252525)),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Color(0xFF9B9B9B),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      var coinVo = walletVo.coins[index];
                      var coinVoJsonStr =
                          FluroConvertUtils.object2string(coinVo.toJson());
                      Application.router.navigateTo(
                          context,
                          Routes.wallet_account_detail +
                              '?coinVo=$coinVoJsonStr');
                    },
                    child: _buildAccountItem(context, walletVo.coins[index]));
              },
              itemCount: walletVo.coins.length,
            )
          ]),
    );
  }

  Widget _buildAccountItem(BuildContext context, CoinVo coin) {
    var symbolQuote =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign(coin.symbol);
    var isNetworkUrl = coin.logo.contains("http");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF9B9B9B), width: 0),
              shape: BoxShape.circle,
            ),
            child: getCoinImage(isNetworkUrl, coin.logo),
          ),
          SizedBox(
            width: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  coin.symbol,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF252525)),
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "${symbolQuote?.sign?.sign ?? ''} ${WalletUtil.formatPrice(symbolQuote?.quoteVo?.price ?? 0.0)}",
                        style: TextStyles.textC9b9b9bS12,
                      ),
                    ),
                    if(symbolQuote?.quoteVo?.percentChange24h != null)
                      getPercentChange(symbolQuote?.quoteVo?.percentChange24h)
                  ],
                )
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "${WalletUtil.formatCoinNum(coin.balance)}",
                  style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${symbolQuote?.sign?.sign ?? ''} ${WalletUtil.formatPrice(coin.balance * (symbolQuote?.quoteVo?.price ?? 0))}",
                    style: TextStyles.textC9b9b9bS12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getPercentChange(double percentChange) {
      if (percentChange > 0) {
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            "${WalletUtil.formatPercentChange(percentChange)}",
            style: TextStyles.textC00ec00S12,
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            "${WalletUtil.formatPercentChange(percentChange)}",
            style: TextStyles.textCff2d2dS12,
          ),
        );
      }
  }

  Widget getCoinImage(bool isNetworkUrl, String imageUrl) {
    if (!isNetworkUrl) {
      return Image.asset(imageUrl);
    }
    return FadeInImage.assetNetwork(
      placeholder: 'res/drawable/img_placeholder_circle.png',
      image: imageUrl,
      fit: BoxFit.cover,
    );
  }
}
