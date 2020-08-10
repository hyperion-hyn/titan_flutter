import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/pages/market/model/asset_type.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

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

class _ExchangeAssetHistoryPageState
    extends BaseState<ExchangeAssetHistoryPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  ActiveQuoteVoAndSign symbolQuote;
  List<AssetHistory> _assetHistoryList = List();
  ExchangeApi _exchangeApi = ExchangeApi();
  int _currentPage = 1;
  int _size = 20;
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  Decimal ethToCurrency;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    symbolQuote =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign('USDT');
    _updateTypeToCurrency();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _loadDataBloc.close();
  }

  _updateTypeToCurrency() async {
    try {
      var ethRet = await _exchangeApi.type2currency(
        'ETH',
        symbolQuote?.sign?.quote,
      );
      ethToCurrency = Decimal.parse(ethRet.toString());

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
            '财务记录',
            style: TextStyle(color: Colors.black, fontSize: 18),
          )),
      body: Container(
        color: Colors.white,
        child: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullUp: _assetHistoryList.isNotEmpty,
          onLoadData: () {
            _refresh();
          },
          onLoadingMore: () {
            _loadMore();
          },
          onRefresh: () {
            BlocProvider.of<ExchangeCmpBloc>(context).add(UpdateAssetsEvent());
            _refresh();
            _loadDataBloc.add(RefreshSuccessEvent());
          },
          child: _content(),
        ),
      ),
    );
  }

  _content() {
    if (_assetHistoryList.isEmpty) {
      return Column(
        children: <Widget>[
          _assetLayout(),
          Expanded(
            child: Center(
              child: Container(
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'res/drawable/ic_empty_list.png',
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      '暂无记录',
                      style: TextStyle(
                        color: HexColor('#FF999999'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return ListView.builder(
          itemCount: _assetHistoryList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _assetLayout();
            } else {
              return _assetHistoryItem(_assetHistoryList[index]);
            }
          });
    }
  }

  _assetLayout() {
    String _logoPath = '';
    if (widget._symbol == 'HYN') {
      _logoPath = SupportedTokens.HYN.logo;
    } else if (widget._symbol == 'ETH') {
      _logoPath = SupportedTokens.ETHEREUM.logo;
    } else if (widget._symbol == 'USDT') {
      _logoPath = SupportedTokens.USDT_ERC20.logo;
    }
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
                        _logoPath,
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
                      )
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
    if (widget._symbol == 'HYN') {
      return AssetItem(
        ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            .HYN,
        ethToCurrency,
      );
    } else if (widget._symbol == 'USDT') {
      return AssetItem(
        ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            .USDT,
        ethToCurrency,
      );
    } else if (widget._symbol == 'ETH') {
      return AssetItem(
        ExchangeInheritedModel.of(context)
            .exchangeModel
            .activeAccount
            .assetList
            .ETH,
        ethToCurrency,
      );
    } else {
      return SizedBox();
    }
  }

  _assetHistoryItem(AssetHistory assetHistory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          assetHistory.name == 'recharge' ? '钱包到交易账户' : '交易账户到钱包',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
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
                          '数量(${assetHistory.type})',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          "${assetHistory.balance}",
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
                    '状态',
                    style: TextStyle(
                      color: DefaultColors.color999,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    '${assetHistory.status}',
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
                    '时间',
                    style: TextStyle(
                      color: DefaultColors.color999,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      Text(
                        FormatUtil.formatMarketOrderDate(
                          assetHistory.ctime,
                        ),
                        style: TextStyle(
                          color: DefaultColors.color333,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF5F5F5'),
    );
  }

  _refresh() async {
    _currentPage = 1;

    ///clear list before refresh
    _assetHistoryList.clear();

    try {
      List<AssetHistory> resultList = await _exchangeApi.getAccountHistory(
        widget._symbol,
        _currentPage,
        _size,
        'all',
      );
      _assetHistoryList.addAll(resultList);
    } catch (e) {}
    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    _currentPage++;
    try {
      List<AssetHistory> resultList = await _exchangeApi.getAccountHistory(
        widget._symbol,
        _currentPage,
        _size,
        'all',
      );
      _assetHistoryList.addAll(resultList);
    } catch (e) {}
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }
}

class AssetItem extends StatefulWidget {
  final AssetType _assetType;
  final Decimal _ethToCurrency;

  AssetItem(
    this._assetType,
    this._ethToCurrency,
  );

  @override
  State<StatefulWidget> createState() {
    return AssetItemState();
  }
}

class AssetItemState extends State<AssetItem> {
  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '折合(${QuotesInheritedModel.of(context, aspect: QuotesAspect.quote).activeQuotesSign.quote})',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          widget._assetType.eth != null &&
                                  widget._ethToCurrency != null
                              ? '${FormatUtil.truncateDecimalNum(
                                  Decimal.parse(widget._assetType.eth) *
                                      widget._ethToCurrency,
                                  4,
                                )}'
                              : '-',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12),
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
                    '可用',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    Decimal.parse(widget._assetType.exchangeAvailable)
                        .toString(),
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
                    '冻结',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      Text(
                        Decimal.parse(widget._assetType.exchangeFreeze)
                            .toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
