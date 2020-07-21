import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_list.dart';
import 'package:titan/src/pages/market/model/asset_type.dart';
import 'deposit_page.dart';
import 'withdraw_page.dart';

class BalancesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BalancesPageState();
  }
}

class _BalancesPageState extends BaseState<BalancesPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
            '资产',
            style: TextStyle(color: Colors.black, fontSize: 18),
          )),
      body: LoadDataContainer(
        bloc: _loadDataBloc,
        onRefresh: () {
          BlocProvider.of<ExchangeCmpBloc>(context).add(UpdateAssetsEvent());
          _loadDataBloc.add(RefreshSuccessEvent());
        },
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 16,
              ),
              _totalBalances(),
              _divider(),
              Expanded(
                child: _accountTabView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _totalBalances() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '总资产估值(BTC)',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: <Widget>[
                      Text(
                        ExchangeInheritedModel.of(context)
                                .exchangeModel
                                .isShowBalances
                            ? '3.34563667'
                            : '*****',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        ExchangeInheritedModel.of(context)
                                .exchangeModel
                                .isShowBalances
                            ? '≈1923443.34 CNY'
                            : '*****',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 3,
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 30,
                      child: OutlineButton(
                        child: Text(
                          '充币',
                          style: TextStyle(color: HexColor('#FF1095B0')),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DepositPage()));
                        },
                        borderSide: BorderSide(
                          color: HexColor('#FF1095B0'),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 30,
                      child: OutlineButton(
                        child: Text(
                          '划转',
                          style: TextStyle(color: HexColor('#FF1095B0')),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WithdrawPage()));
                        },
                        borderSide: BorderSide(
                          color: HexColor('#FF1095B0'),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Positioned(
            right: 8,
            top: 0,
            child: InkWell(
              onTap: () async {
                BlocProvider.of<ExchangeCmpBloc>(context).add(
                    SetShowBalancesEvent(!ExchangeInheritedModel.of(context)
                        .exchangeModel
                        .isShowBalances));
                setState(() {});
              },
              child: ExchangeInheritedModel.of(context)
                      .exchangeModel
                      .isShowBalances
                  ? Image.asset(
                      'res/drawable/ic_wallet_show_balances.png',
                      height: 20,
                      width: 20,
                      color: HexColor('#FF228BA1'),
                    )
                  : Image.asset(
                      'res/drawable/ic_wallet_hide_balances.png',
                      height: 20,
                      width: 20,
                      color: HexColor('#FF228BA1'),
                    ),
            ),
          )
        ],
      ),
    );
  }

  _accountTabView() {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: new Container(
            width: double.infinity,
            height: 50.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: TabBar(
                    labelColor: HexColor('#FF228BA1'),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: HexColor('#FF228BA1'),
                    indicatorWeight: 3,
                    indicatorPadding: EdgeInsets.only(bottom: 2),
                    unselectedLabelColor: HexColor("#FF333333"),
                    tabs: [
                      Tab(
                        child: Text(
                          '资金账户',
                        ),
                      ),
                      Tab(
                        child: Text(
                          '交易账户',
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _accountAssetListView(
              ExchangeInheritedModel.of(context)
                  .exchangeModel
                  .activeAccount
                  .assetList,
            ),
            _exchangeAssetListView(ExchangeInheritedModel.of(context)
                .exchangeModel
                .activeAccount
                .assetList),
          ],
        ),
      ),
    );
    ;
  }

  _accountAssetListView(AssetList _assetList) {
    if (_assetList != null) {
      return ListView(
        children: <Widget>[
          AssetItem('account', 'HYN', _assetList.HYN),
          AssetItem('account', 'USDT', _assetList.USDT),
          AssetItem('account', 'ETH', _assetList.ETH),
          AssetItem('account', 'BTC', _assetList.BTC),
        ],
      );
    } else {
      return Container(
        child: Center(
          child: Text('加载中'),
        ),
      );
    }
  }

  _exchangeAssetListView(AssetList _assetList) {
    if (_assetList != null) {
      return ListView(
        children: <Widget>[
          AssetItem('exchange', 'HYN', _assetList.HYN),
          AssetItem('exchange', 'USDT', _assetList.USDT),
          AssetItem('exchange', 'ETH', _assetList.ETH),
          AssetItem('exchange', 'BTC', _assetList.BTC),
        ],
      );
    } else {
      return Container(
        child: Center(
          child: Text('加载中'),
        ),
      );
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
  final String _accountType;
  final String _symbol;
  final AssetType _assetType;

  AssetItem(
    this._accountType,
    this._symbol,
    this._assetType,
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
                      color: HexColor('#FF228BA1'),
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
                            widget._accountType == 'exchange'
                                ? widget._assetType.exchangeAvailable
                                : widget._assetType.accountAvailable,
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
                      '冻结',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      widget._accountType == 'exchange'
                          ? widget._assetType.exchangeFreeze
                          : widget._assetType.accountFreeze,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
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
                      '折合(CNY)',
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
                          '${widget._assetType.btc}',
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
        ),
        SizedBox(
          height: 4.0,
        ),
        _divider()
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
