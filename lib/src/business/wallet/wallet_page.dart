import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/business/wallet/wallet_empty_widget.dart';
import 'package:titan/src/business/wallet/wallet_show_widget.dart';
import 'package:titan/src/global.dart';

import 'api/market_price_api.dart';
import 'event_bus_event.dart';
import 'market_price_page.dart';
import 'model/hyn_market_price_response.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

class _WalletPageState extends State<WalletPage> with RouteAware {
  WalletBloc _walletBloc;

  MarketPriceApi _marketPriceApi = MarketPriceApi();

  StreamSubscription _eventbusSubcription;

  WalletService _walletService = WalletService();

  var marketPriceResponse = HynMarketPriceResponse(
    0,
    0,
    [],
    0,
  );

  NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.#####");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    print("didPopNext");
    doDidPopNext();
  }

  Future doDidPopNext() async {
    if (currentWalletVo != null) {
      String defaultWalletFileName = await _walletService.getDefaultWalletFileName();
      logger.i("defaultWalletFileName:$defaultWalletFileName");
      String updateWalletFileName = currentWalletVo.wallet.keystore.fileName;
      logger.i("updateWalletFileName:$updateWalletFileName");
      if (defaultWalletFileName == updateWalletFileName) {
        logger.i("do UpdateWalletEvent");
        _walletBloc.add(UpdateWalletEvent(currentWalletVo));
      } else {
        currentWalletVo = null;
        logger.i("do ScanWalletEvent");
        _walletBloc.add(ScanWalletEvent());
      }
    } else {
      _walletBloc.add(ScanWalletEvent());
    }
  }

  @override
  void initState() {
    super.initState();

    _walletBloc = WalletBloc();
    _walletBloc.add(ScanWalletEvent());

    _getPrice();

    _eventbusSubcription = eventBus.on().listen((event) {
      if (event is ReScanWalletEvent) {
        _walletBloc.add(ScanWalletEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: _buildWalletView(context)),
        InkWell(
          child: Container(
            padding: EdgeInsets.all(8),
            color: Color(0xFFF5F5F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(
                          'res/drawable/ic_hyperion.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      Text(
                        S.of(context).hyn_price,
                        style: TextStyle(color: Color(0xFF6D6D6D), fontSize: 14),
                      ),
                      //Container(width: 100,),
                      Spacer(),
                      Text(
                        '${DOUBLE_NUMBER_FORMAT.format(appLocale.languageCode == "zh" ? marketPriceResponse.avgCNYPrice : marketPriceResponse.avgPrice)} ${S.of(context).hynPriceUnit}',
                        style: TextStyle(color: HexColor('#333333'), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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
          currentWalletVo = state.wallet;
          return Container(
            child: ShowWallet(state.wallet),
          );
        } else if (state is ScanWalletLoadingState) {
          return buildLoading(context);
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildLoading(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  Future _getPrice() async {
    marketPriceResponse = await _marketPriceApi.getHynMarketPriceResponse();
    setState(() {});
  }

  @override
  void dispose() {
    _eventbusSubcription?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}
