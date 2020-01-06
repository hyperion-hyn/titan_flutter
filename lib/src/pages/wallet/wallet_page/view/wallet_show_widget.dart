import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/routes.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_widget.dart';

class ShowWalletView extends StatelessWidget {
  final WalletVo walletVo;

  ShowWalletView(this.walletVo);

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
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 16),
                  child: Row(
                    children: <Widget>[
                      //balance
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${QuotesViewModel.of(context, aspect: QuotesAspect.quote).activeQuotesSign?.quote ?? ''}",
                            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 16),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                QuotesViewModel.of(context, aspect: QuotesAspect.quote).activeQuotesSign?.sign ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "${WalletViewModel.formatPrice(walletVo.balance)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Application.router.navigateTo(context, Routes.wallet_manager);
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
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShowAccountPage(walletVo.coins[index]),
                              settings: RouteSettings(name: "/show_account_page")));
                    },
                    child: _buildAccountItem(context, walletVo.coins[index]));
              },
              itemCount: walletVo.coins.length,
            )
          ]),
    );
  }

  Widget _buildAccountItem(BuildContext context, CoinVo coin) {
    var symbolQuote = QuotesViewModel.of(context).currentSymbolQuote(coin.symbol);
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
            child: Image.asset(coin.logo),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF252525)),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${symbolQuote.sign.sign} ${WalletViewModel.formatPrice(symbolQuote.quoteVo.price)}",
                    style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                  ),
                ),
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
                  "${WalletViewModel.formatPrice(coin.balance)}",
                  style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${symbolQuote.sign.sign} ${WalletViewModel.formatPrice(coin.balance * symbolQuote.quoteVo.price)}",
                    style: TextStyle(fontSize: 14, color: HexColor("#FF848181")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
