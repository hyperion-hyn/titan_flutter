import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/widget/hyn_burn_banner.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

class ShowWalletView extends StatefulWidget {
  final WalletVo walletVo;
  final LoadDataBloc loadDataBloc;

  ShowWalletView(this.walletVo, this.loadDataBloc);

  @override
  State<StatefulWidget> createState() {
    return _ShowWalletViewState();
  }
}

class _ShowWalletViewState extends BaseState<ShowWalletView> {
  int _lastRequestCoinTime = 0;
  bool _isShowBalances = true;
  bool _isRefreshBalances = false;
  bool _isRefreshFail = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.loadDataBloc.close();
    super.dispose();
  }

  @override
  void onCreated() {
    BlocProvider.of<WalletCmpBloc>(context).listen((state) {
      if (state is UpdateWalletPageState && state.updateStatus == 0) {
        if(mounted){
          setState(() {
            _isRefreshBalances = false;
            _isRefreshFail = false;
          });
        }
      }else if(state is UpdateWalletPageState && (state.updateStatus == -1)){
        if(mounted){
          setState(() {
            _isRefreshBalances = false;
            _isRefreshFail = true;
          });
        }
      }else if(state is UpdateWalletPageState && (state.updateStatus == 1)){
        if(mounted){
          setState(() {
            _isRefreshFail = false;
            _isRefreshBalances = true;
          });
        }
      }
    });
    // BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletPageEvent());
    super.onCreated();
  }

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
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                WalletManagerPage.jumpWalletManager(context, hasWalletUpdate: (wallet) {
                                  setState(() {
                                    _isRefreshFail = false;
                                    _isRefreshBalances = true;
                                  });
                                }, noWalletUpdate: () {
                                  setState(() {});
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "${UiUtil.shortString(
                                      widget.walletVo.wallet.keystore.name,
                                      limitLength: 6,
                                    )}",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  _isShowBalances = !_isShowBalances;
                                });
                              },
                              child: _isShowBalances
                                  ? Image.asset(
                                      'res/drawable/ic_wallet_show_balances.png',
                                      height: 20,
                                      width: 20,
                                    )
                                  : Image.asset(
                                      'res/drawable/ic_wallet_hide_balances.png',
                                      height: 20,
                                      width: 20,
                                    ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            WalletInheritedModel.of(context, aspect: WalletAspect.quote).activeQuotesSign?.sign ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            _isShowBalances ? '${FormatUtil.formatPrice(widget.walletVo.balance)}' : '*****',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          if (_isRefreshBalances)
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                strokeWidth: 1,
                              ),
                            ),
                          if(_isRefreshFail)
                            Text("刷新失败", style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ))
                        ],
                      ),
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
                var coinVo = widget.walletVo.coins[index];
                var hasPrice = true;
                // if(coinVo.symbol == SupportedTokens.HYN_RP_HRC30_ROPSTEN.symbol){
                //   hasPrice = false;
                // }
                return InkWell(
                    onTap: () {
                      var coinVo = widget.walletVo.coins[index];
                      var coinVoJsonStr = FluroConvertUtils.object2string(coinVo.toJson());
                      Application.router.navigateTo(context, Routes.wallet_account_detail + '?coinVo=$coinVoJsonStr');
                    },
                    child: _buildAccountItem(context, coinVo, hasPrice: hasPrice));
              },
              itemCount: widget.walletVo.coins.length,
            ),
            if (widget.walletVo.wallet.getBitcoinAccount() == null) _bitcoinEmptyView(context),
            SizedBox(
              height: 16,
            ),
            HynBurnBanner(),
//            if (env.buildType == BuildType.DEV) _ropstenTestWalletView(context),
          ]),
    );
  }

  Widget _bitcoinEmptyView(BuildContext context) {
    var coinVo = CoinVo(
      name: "BITCOIN",
      symbol: "BTC",
      coinType: 0,
      address: "",
      decimals: 8,
      logo: "res/drawable/ic_btc_logo_empty.png",
      contractAddress: null,
      extendedPublicKey: "",
      balance: BigInt.from(0),
    );
    return InkWell(
      onTap: () async {
        var walletPassword = await UiUtil.showWalletPasswordDialogV2(
          context,
          widget.walletVo.wallet,
        );

        if (walletPassword == null) {
          return;
        }
        try {
          await widget.walletVo.wallet.bitcoinActive(walletPassword);
          BlocProvider.of<WalletCmpBloc>(context).add(LoadLocalDiskWalletAndActiveEvent());
          Future.delayed(Duration(milliseconds: 500), () {
            widget.loadDataBloc.add(LoadingEvent());
          });
        } catch (error) {
          LogUtil.toastException(error);
        }
      },
      child: Column(
        children: <Widget>[
          _buildAccountItem(context, coinVo),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset(
                "res/drawable/ic_key_view.png",
                width: 16,
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 16),
                child: Text(
                  S.of(context).activate_btc,
                  style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _testWalletView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('atlas detail'),
            onPressed: () async {
              Application.router.navigateTo(context, Routes.atlas_detail_page);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, CoinVo coin, {bool hasPrice = true}) {
    var symbol = coin.symbol;
    var symbolQuote = WalletInheritedModel.of(context).activatedQuoteVoAndSign(symbol);
    var subSymbol = "";

    if (coin.coinType == CoinType.HYN_ATLAS) {
      subSymbol = '';
    } else if (coin.coinType == CoinType.ETHEREUM) {
      var symbolComponents = symbol.split(" ");
      if (symbolComponents.length == 2) {
        symbol = symbolComponents.first;
        subSymbol = symbolComponents.last.toLowerCase();
      }
    }

    var quotePrice;
    var balancePrice;
    if (!hasPrice) {
      quotePrice = S.of(context).exchange_soon;
      balancePrice = "";
    } else {
      quotePrice = "${symbolQuote?.sign?.sign ?? ''} ${FormatUtil.formatPrice(symbolQuote?.quoteVo?.price ?? 0.0)}";
      balancePrice = _isShowBalances
          ? "${symbolQuote?.sign?.sign ?? ''} ${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(coin) * (symbolQuote?.quoteVo?.price ?? 0))}"
          : '${symbolQuote?.sign?.sign ?? ''} *****';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            child: ImageUtil.getCoinImage(coin.logo),
          ),
          SizedBox(
            width: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF252525)),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      subSymbol,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Padding(
                //       padding: const EdgeInsets.symmetric(vertical: 4),
                //       child: Text(
                //         quotePrice,
                //         style: TextStyles.textC9b9b9bS12,
                //       ),
                //     ),
                //     if (symbolQuote?.quoteVo?.percentChange24h != null)
                //       getPercentChange(symbolQuote?.quoteVo?.percentChange24h)
                //   ],
                // )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _isShowBalances ? "${FormatUtil.coinBalanceHumanReadFormat(coin)}" : '*****',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      balancePrice,
                      style: TextStyles.textC9b9b9bS12,
                    ),
                  ),
                ],
              ),
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
          "+${FormatUtil.formatPercentChange(percentChange)}",
          style: TextStyles.textC00ec00S12,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Text(
          "${FormatUtil.formatPercentChange(percentChange)}",
          style: TextStyles.textCff2d2dS12,
        ),
      );
    }
  }
}
