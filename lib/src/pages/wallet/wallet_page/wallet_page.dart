import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/config/application.dart';

import 'view/wallet_empty_widget.dart';
import 'view/wallet_show_widget.dart';
import 'bloc/bloc.dart';

class WalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

class _WalletPageState extends State<WalletPage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    doDidPopNext();
  }

  Future doDidPopNext() async {
//    var activatedWallet = WalletViewModel.of(context, aspect: WalletAspect.activatedWallet).activatedWallet;
//    if (activatedWallet != null) {
//      String defaultWalletFileName = await _walletService.getDefaultWalletFileName();
//      String updateWalletFileName = activatedWallet.wallet.keystore.fileName;
//      if (defaultWalletFileName == updateWalletFileName) {
//        _walletBloc.add(UpdateWalletEvent(activatedWallet));
//      } else {
//        _walletBloc.add(ScanWalletEvent());
//      }
//    } else {
//      _walletBloc.add(ScanWalletEvent());
//    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //hyn quote
    SymbolQuote hynQuote = QuotesViewModel.of(context).currentSymbolQuote('HYN');

    return Column(
      children: <Widget>[
        Expanded(child: _buildWalletView(context)),
        //hyn quotes view
        Container(
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
                    //quote
                    Text(
                      '${hynQuote != null ? '${hynQuote.quoteVo.price} ${hynQuote.sign.sign}' : '--'}',
                      style: TextStyle(color: HexColor('#333333'), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWalletView(BuildContext context) {
    return BlocBuilder<WalletPageBloc, WalletPageState>(
      builder: (BuildContext context, WalletPageState state) {
        if (state is EmptyWallet) {
          return EmptyWallet();
        } else if (state is WalletLoadedState) {
          return ShowWalletView(state.walletVo);
        } else if (state is LoadingWalletState) {
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

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
  }
}
