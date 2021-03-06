import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/exchange/model.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/components/wallet/vo/token_price_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_list.dart';
import 'package:titan/src/pages/market/transfer/exchange_asset_history_page.dart';
import 'package:titan/src/pages/market/model/asset_type.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/popup/pop_route.dart';
import 'package:titan/src/widget/popup/pop_widget.dart';

import 'order/exchange_order_mangement_page.dart';

class ExchangeAssetsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangeAssetsPageState();
  }
}

class _ExchangeAssetsPageState extends BaseState<ExchangeAssetsPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  ExchangeApi _exchangeApi = ExchangeApi();
  TokenPriceViewVo symbolQuote;
  Decimal _usdtToCurrency;
  ExchangeModel _exchangeModel;

  TransactionInteractor transactionInteractor;
  var hasPendingDepositTx = false;
  var usdtExchangeAddress;

  @override
  void onCreated() {
    symbolQuote = WalletInheritedModel.of(context).tokenLegalPrice('USDT');
    _exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;

    transactionInteractor = Injector.of(context).transactionInteractor;

    // WidgetsBinding.instance.addPostFrameCallback((callback) {
    //   _refreshAssets();
    // });
    // _refreshAssets();

    super.onCreated();
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
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
          S.of(context).exchange_account,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExchangeOrderManagementPage(''),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                "res/drawable/ic_exhange_all_consign.png",
                width: 15,
                height: 15,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _showOptionsPopup();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                "res/drawable/k_line_setting.png",
                width: 15,
                height: 15,
              ),
            ),
          ),
          SizedBox(width: 16)
        ],
      ),
      body: Column(
        children: [
          if (hasPendingDepositTx)
            InkWell(
              onTap: () {
                var coinVo = WalletInheritedModel.of(context)
                    .getCoinVoBySymbolAndCoinType('USDT', CoinType.ETHEREUM);
                if (coinVo != null) {
                  var coinVoJsonStr = FluroConvertUtils.object2string(coinVo.toJson());
                  Application.router
                      .navigateTo(context, Routes.wallet_account_detail + '?coinVo=$coinVoJsonStr');
                }
              },
              child: Container(
                color: Color(0xFFE7F2FB),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      S.of(context).charge_usdt_waiting_confirmation,
                      style: TextStyle(fontSize: 12),
                    ),
                    Spacer(),
                    Text(S.of(context).check, style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: LoadDataContainer(
                bloc: _loadDataBloc,
                enablePullUp: false,
                onLoadData: () async {
                  _refreshAssets();
                  _loadDataBloc.add(RefreshSuccessEvent());
                },
                onRefresh: () async {
                  _refreshAssets();
                  _loadDataBloc.add(RefreshSuccessEvent());
                },
                child: ListView(
                  children: <Widget>[
                    _totalBalances(),
                    _divider(),
                    _exchangeAssetListView(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showOptionsPopup() {
    return Navigator.push(
      context,
      PopRoute(
        child: Popup(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    ///close popup
                    Navigator.of(context).pop();

                    ///close asset page
                    Navigator.of(context).pop();
                    WalletManagerPage.jumpWalletManager(context);

                    /*Application.router
                        .navigateTo(context, Routes.wallet_manager);*/
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(S.of(context).exchange_change_wallet),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    showLogoutDialog(context, () {
                      ///
                      BlocProvider.of<ExchangeCmpBloc>(context).add(ClearExchangeAccountEvent());
                      Navigator.of(context).pop();
                      Routes.popUntilCachedEntryRouteName(context);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(S.of(context).exchange_logout),
                  ),
                )
              ],
            ),
          ),
          left: 250,
          top: 66,
        ),
      ),
    );
  }

  _refreshAssets() async {
    if (_exchangeModel.hasActiveAccount()) {
      BlocProvider.of<ExchangeCmpBloc>(context).add(UpdateAssetsEvent());
      await _updateTypeToCurrency();
    } else {
      UiUtil.showExchangeAuthAgainDialog(context);
    }

    // 只显示USDT的pending转账提示
    if (usdtExchangeAddress == null) {
      var ret = await _exchangeApi.getAddressV2('USDT', 'erc20');
      usdtExchangeAddress = ret['address'];
    }
    var lastPendingState = hasPendingDepositTx;
    var ethAddress =
        WalletInheritedModel.of(context)?.activatedWallet?.wallet?.getEthAccount()?.address;
    await transactionInteractor.removeLocalPendingConfirmedTxsOfAddress(
        ethAddress, LocalTransferType.LOCAL_TRANSFER_ERC20, EthereumConfig.getUsdtErc20Address());
    var localPendingTxs = await transactionInteractor.getLocalPendingTransactions(
        ethAddress, LocalTransferType.LOCAL_TRANSFER_ERC20, EthereumConfig.getUsdtErc20Address());
    var hasPending = false;
    for (var tx in localPendingTxs) {
      if (tx.toAddress == usdtExchangeAddress) {
        setState(() {
          hasPending = true;
        });
        break;
      }
    }
    hasPendingDepositTx = hasPending;
    if (hasPendingDepositTx != lastPendingState) {
      setState(() {});
    }
  }

  _totalBalances() {
    var _exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;
    var _isShowBalances = ExchangeInheritedModel.of(context).exchangeModel.isShowBalances;
    var _totalByHyn = '--';
    var _totalByUsdt = '--';
    var _totalUSDTQuotePrice = '--';

    try {
      _totalByHyn = _exchangeModel.isActiveAccountAndHasAssets()
          ? FormatUtil.truncateDecimalNum(_exchangeModel.activeAccount?.assetList?.totalByHYN(), 6)
          : '--';
      if (_exchangeModel.isActiveAccountAndHasAssets()) {
        _totalUSDTQuotePrice = FormatUtil.truncateDecimalNum(
            _usdtToCurrency * _exchangeModel.activeAccount?.assetList?.totalByUSDT(), 4);
      }
    } catch (e) {}

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).exchange_total_balance,
                      style: TextStyle(fontSize: 12.0, color: HexColor('FF999999')),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: <Widget>[
                        Text(
                          _isShowBalances ? '$_totalByHyn HYN' : '***** HYN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          _isShowBalances
                              ? _usdtToCurrency == null ||
                                      _totalByHyn == null ||
                                      _totalByUsdt == null
                                  ? '--'
                                  : '≈ $_totalUSDTQuotePrice ${symbolQuote?.legal?.legal ?? '-'}'
                              : '≈ ***** ${symbolQuote?.legal?.legal ?? '-'}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: HexColor('#FF999999')),
                          maxLines: 3,
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 30,
                        width: 112,
                        child: OutlineButton(
                          child: Text(
                            S.of(context).exchange_transfer,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            if (ExchangeInheritedModel.of(context)
                                .exchangeModel
                                .hasActiveAccount()) {
                              Application.router.navigateTo(
                                context,
                                Routes.exchange_transfer_page,
                              );
                            } else {
                              UiUtil.showExchangeAuthAgainDialog(context);
                            }
                          },
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        height: 30,
                        width: 112,
                        child: OutlineButton(
                          child: Text(
                            S.of(context).ordinary_deposit,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            if (ExchangeInheritedModel.of(context)
                                .exchangeModel
                                .hasActiveAccount()) {
                              Application.router.navigateTo(
                                context,
                                Routes.exchange_qrcode_deposit_page,
                              );
                            } else {
                              UiUtil.showExchangeAuthAgainDialog(context);
                            }
                          },
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              right: 8,
              top: 16,
              child: InkWell(
                onTap: () async {
                  BlocProvider.of<ExchangeCmpBloc>(context)
                      .add(SetShowBalancesEvent(!_isShowBalances));
                  setState(() {});
                },
                child: _isShowBalances
                    ? Image.asset(
                        'res/drawable/ic_wallet_show_balances.png',
                        height: 20,
                        width: 20,
                        color: Theme.of(context).primaryColor,
                      )
                    : Image.asset(
                        'res/drawable/ic_wallet_hide_balances.png',
                        height: 20,
                        width: 20,
                        color: Theme.of(context).primaryColor,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _exchangeAssetListView() {
    var _exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;
    var _assetList = _exchangeModel.isActiveAccountAndHasAssets()
        ? _exchangeModel?.activeAccount?.assetList
        : null;
    var _isShowBalances = ExchangeInheritedModel.of(context)?.exchangeModel?.isShowBalances ?? true;
    var activeTokens = MarketInheritedModel.of(
      context,
      aspect: SocketAspect.marketItemList,
    ).activeAssets();

    List<Widget> assetItemList = [Container()];

    activeTokens.forEach((tokenName) {
      var tokenAsset = _assetList?.getTokenAsset(tokenName);
      if (tokenAsset != null) {
        assetItemList.add(
          AssetItem(
            tokenName,
            tokenAsset,
            _usdtToCurrency,
            _isShowBalances,
          ),
        );
      }
    });

    if (_assetList != null) {
      return Container(
        color: Colors.white,
        child: Column(
          children: assetItemList,
        ),
      );
    } else {
      return _emptyView();
    }
  }

  static Future<T> showLogoutDialog<T>(
    BuildContext context,
    Function onClick,
  ) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            )),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  S.of(context).exchange_logout_hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.8),
                ),
              ),
            ),
            content: Wrap(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 32,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: InkWell(
                            child: Text(
                              S.of(context).cancel,
                              style: TextStyle(
                                color: HexColor('#FF999999'),
                              ),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Expanded(
                      child: ClickOvalButton(
                        S.of(context).exchange_logout,
                        () async {
                          Navigator.pop(context);
                          onClick();
                        },
                        height: 45,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  _emptyView() {
    var _exchangeModel = ExchangeInheritedModel.of(context).exchangeModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 48,
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
          _exchangeModel.hasActiveAccount()
              ? S.of(context).exchange_empty_list
              : S.of(context).exchange_login_before_view_orders,
          style: TextStyle(
            color: HexColor('#FF999999'),
          ),
        )
      ],
    );
  }

  _updateTypeToCurrency() async {
    try {
      var ret = await _exchangeApi.type2currency(
        'USDT',
        symbolQuote?.legal?.legal,
      );
      _usdtToCurrency = Decimal.parse(ret.toString());

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF5F5F5'),
    );
  }
}

class AssetItem extends StatefulWidget {
  final String _symbol;
  final AssetType _assetType;
  final bool _isShowBalances;
  final Decimal _usdtToCurrency;

  AssetItem(
    this._symbol,
    this._assetType,
    this._usdtToCurrency,
    this._isShowBalances,
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
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExchangeAssetHistoryPage(widget._symbol),
            ));
      },
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget._symbol,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: DefaultColors.color999,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          widget._isShowBalances ? exchangeAvailable : '*****',
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
                        S.of(context).exchange_frozen,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        widget._isShowBalances ? exchangeFreeze : '*****',
                        style: TextStyle(
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
                        '${S.of(context).exchange_asset_convert}(${WalletInheritedModel.of(context, aspect: WalletAspect.quote).activeLegal?.legal ?? '-'})',
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              ExchangeInheritedModel.of(context).exchangeModel.isShowBalances
                                  ? balanceByCurrency
                                  : '*****',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: DefaultColors.color999,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          _divider()
        ],
      ),
    );
  }

  _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Divider(
        height: 2,
      ),
    );
  }
}
