import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_event.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/vo/token_price_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/pages/market/model/asset_type.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/wallet_show_trasaction_simple_info_page.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class ExchangeAssetHistoryPage extends StatefulWidget {
  final String _symbol;

  ExchangeAssetHistoryPage(
    this._symbol,
  );

  @override
  State<StatefulWidget> createState() {
    return _ExchangeAssetHistoryPageState();
  }
}

class _ExchangeAssetHistoryPageState extends BaseState<ExchangeAssetHistoryPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  TokenPriceViewVo symbolQuote;
  List<AssetHistory> _assetHistoryList = List();
  ExchangeApi _exchangeApi = ExchangeApi();
  int _currentPage = 1;
  int _size = 20;
  Decimal _usdtToCurrency;

  @override
  void initState() {
    super.initState();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void onCreated() {
    super.onCreated();
    symbolQuote = WalletInheritedModel.of(context).tokenLegalPrice('USDT');
    _updateTypeToCurrency();
  }

  @override
  void dispose() {
    _loadDataBloc.close();
    super.dispose();
  }

  _updateTypeToCurrency() async {
    try {
      var usdt = await _exchangeApi.type2currency(
        'USDT',
        symbolQuote?.legal?.legal,
      );
      _usdtToCurrency = Decimal.parse(usdt.toString());

      setState(() {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            S.of(context).exchange_asset_history,
            style: TextStyle(color: Colors.black, fontSize: 18),
          )),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              LoadDataContainer(
                bloc: _loadDataBloc,
                enablePullUp: _assetHistoryList.isNotEmpty,
                onLoadData: () async {
                  _refresh();
                },
                onLoadingMore: () async {
                  await _loadMore();
                },
                onRefresh: () async {
                  BlocProvider.of<ExchangeCmpBloc>(context).add(UpdateAssetsEvent());
                  await _refresh();
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _assetLayout(),
                    ),
                    _content(),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 64,
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ClickOvalButton(
                    S.of(context).exchange_transfer,
                    () {
                      if (ExchangeInheritedModel.of(context)
                          .exchangeModel
                          .isActiveAccountAndHasAssets()) {
                        Application.router.navigateTo(
                          context,
                          '${Routes.exchange_transfer_page}?coinType=${widget._symbol}',
                        );
                      } else {
                        UiUtil.showExchangeAuthAgainDialog(context);
                      }
                    },
                    width: 200,
                    height: 40,
                    btnColor: [HexColor("#F7D33D"), HexColor("#E7C01A")],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontColor: DefaultColors.color333,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'res/drawable/ic_arrow_up.png',
                        width: 12,
                        height: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Container(
              //     width: double.infinity,
              //     child: Padding(
              //       padding: EdgeInsets.only(
              //         left: 64.0,
              //         right: 64,
              //         bottom: 32,
              //       ),
              //       child: Container(
              //         child: RaisedButton(
              //           elevation: 5,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(30),
              //           ),
              //           disabledColor: Colors.grey[600],
              //           color: Theme.of(context).primaryColor,
              //           textColor: Colors.black,
              //           disabledTextColor: Colors.white,
              //           onPressed: () {
              //             if (ExchangeInheritedModel.of(context)
              //                 .exchangeModel
              //                 .isActiveAccountAndHasAssets()) {
              //               Application.router.navigateTo(
              //                 context,
              //                 '${Routes.exchange_transfer_page}?coinType=${widget._symbol}',
              //               );
              //             } else {
              //               UiUtil.showExchangeAuthAgainDialog(context);
              //             }
              //           },
              //           child: Padding(
              //             padding: const EdgeInsets.all(0.0),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: <Widget>[
              //                 Text(
              //                   S.of(context).exchange_transfer,
              //                   style: TextStyle(
              //                     fontWeight: FontWeight.normal,
              //                     fontSize: 14,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  _content() {
    if (_assetHistoryList.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 64,
              ),
              Image.asset(
                'res/drawable/ic_empty_list.png',
                height: 80,
                width: 80,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                S.of(context).exchange_empty_list,
                style: TextStyle(
                  color: HexColor('#FF999999'),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _assetHistoryItem(_assetHistoryList[index]);
          },
          childCount: _assetHistoryList.length,
        ),
      );
    }
  }

  _assetLayout() {
    var token = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbolAndCoinType(widget._symbol, CoinType.HYN_ATLAS);

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset(
                        ImageUtil.getGeneralTokenLogo(widget._symbol),
                        width: 32,
                        height: 32,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        widget._symbol,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _assetItem(),
                ],
              )),
          _divider(),
        ],
      ),
    );
  }

  _assetItem() {
    var asset = ExchangeInheritedModel.of(context)
        ?.exchangeModel
        ?.activeAccount
        ?.assetList
        ?.getTokenAsset(widget._symbol);
    if (asset != null) {
      return AssetItem(
        asset,
        _usdtToCurrency,
      );
    } else {
      return SizedBox();
    }
  }

  _assetHistoryItem(AssetHistory assetHistory) {
    return InkWell(
      onTap: () async {
        if (assetHistory.isAtlas()) {
          var _api = AtlasApi();

          HynTransferHistory hynTransferHistory = await _api.queryHYNTxDetail(
            assetHistory.txId,
          );

          var transactionType = (assetHistory.name ?? '') == 'withdraw' ? 2 : 1;

          var transactionDetailVo = TransactionDetailVo.fromHynTransferHistory(
            hynTransferHistory,
            transactionType,
            assetHistory.type,
          );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WalletShowTransactionSimpleInfoPage(
                      transactionDetailVo.hash, transactionDetailVo.symbol)));
        } else {
          var url = EtherscanApi.getTxDetailUrl(assetHistory.txId);
          if (url != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InAppWebViewContainer(
                          initUrl: url,
                          title: '',
                        )));
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Text(
              assetHistory.getTypeText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${S.of(context).exchange_amount}(${assetHistory.type})',
                              style: TextStyle(
                                color: DefaultColors.color999,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              "${Decimal.parse(assetHistory.balance)}",
                              style: TextStyle(
                                  color: DefaultColors.color333,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        Spacer()
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        S.of(context).exchange_assets_status,
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        assetHistory.getStatusText(),
                        maxLines: 2,
                        style: TextStyle(
                          color: DefaultColors.color333,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        S.of(context).exchange_order_time,
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        '${FormatUtil.formatUTCDateStr(assetHistory.ctime)}',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: DefaultColors.color333,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.0,
              ),
              child: Divider(
                height: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF5F5F5'),
    );
  }

  Future _refresh() async {
    _currentPage = 1;

    try {
      List<AssetHistory> resultList = await _exchangeApi.getAccountHistory(
        widget._symbol,
        _currentPage,
        _size,
        'all',
      );

      ///clear list before refresh
      _assetHistoryList.clear();

      ///
      _assetHistoryList.addAll(resultList);
    } catch (e) {}
    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
  }

  _loadMore() async {
    try {
      List<AssetHistory> resultList = await _exchangeApi.getAccountHistory(
        widget._symbol,
        _currentPage + 1,
        _size,
        'all',
      );
      if (resultList.length > 0) {
        _currentPage++;
        _assetHistoryList.addAll(resultList);
      }
    } catch (e) {}
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
  }
}

class AssetItem extends StatefulWidget {
  final AssetType _assetType;
  final Decimal _usdtToCurrency;

  AssetItem(
    this._assetType,
    this._usdtToCurrency,
  );

  @override
  State<StatefulWidget> createState() {
    return AssetItemState();
  }
}

class AssetItemState extends State<AssetItem> {
  @override
  Widget build(BuildContext context) {
    var exchangeAvailable = '-';
    var exchangeFreeze = '-';
    var balanceByCurrency = '-';

    try {
      exchangeAvailable = Decimal.parse(
        widget._assetType.exchangeAvailable,
      ).toString();

      exchangeFreeze = Decimal.parse(
        widget._assetType.exchangeFreeze,
      ).toString();

      balanceByCurrency = FormatUtil.truncateDecimalNum(
        Decimal.parse(widget._assetType.usdt) * widget._usdtToCurrency,
        4,
      );
    } catch (e) {}
    return Column(
      children: <Widget>[
        SizedBox(
          height: 16.0,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${S.of(context).exchange_asset_convert}(${WalletInheritedModel.of(context, aspect: WalletAspect.quote).activeLegal.legal})',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      balanceByCurrency,
                      maxLines: 2,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).exchange_available,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    exchangeAvailable,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    S.of(context).exchange_frozen,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    exchangeFreeze,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 4.0,
        ),
      ],
    );
  }
}
