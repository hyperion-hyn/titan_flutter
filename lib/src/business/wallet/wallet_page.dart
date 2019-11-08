import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/business/wallet/wallet_empty_widget.dart';
import 'package:titan/src/business/wallet/wallet_show_widget.dart';

import 'api/market_price_api.dart';
import 'market_price_page.dart';
import 'model/hyn_market_price_response.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

class _WalletPageState extends State<WalletPage> {
  WalletBloc _walletBloc;

  MarketPriceApi _marketPriceApi = MarketPriceApi();

  var marketPriceResponse = HynMarketPriceResponse(
    0,
    0,
    [],
    0,
  );

  NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.#####");

  @override
  void initState() {
    _walletBloc = WalletBloc();
    _walletBloc.add(ScanWalletEvent());

    _getPrice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildWalletView(context),
        Spacer(),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MarketPricePage()));
          },
          child: Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFFF5F5F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "HYN行情",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                    Spacer(),
                    Text(
                      "查看全部",
                      style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF9B9B9B),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${DOUBLE_NUMBER_FORMAT.format(marketPriceResponse.avgCNYPrice)}人民币",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            "HYN指数",
                            style: TextStyle(color: Color(0xFF6D6D6D), fontSize: 14),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            marketPriceResponse.total.toString(),
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text("上线交易所", style: TextStyle(color: Color(0xFF6D6D6D), fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildWalletView(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      bloc: _walletBloc,
      builder: (BuildContext context, WalletState state) {
        if (state is WalletEmptyState) {
          return Container(
            alignment: Alignment.center,
            child: EmptyWallet(),
          );
        } else if (state is ShowWalletState) {
          return Container(
            child: ShowWallet(state.wallet),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future _getPrice() async {
    marketPriceResponse = await _marketPriceApi.getHynMarketPriceResponse();
    setState(() {});
  }
}
