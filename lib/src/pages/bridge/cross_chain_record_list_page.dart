import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/bridge/bridge_util.dart';
import 'package:titan/src/pages/bridge/entity/cross_chain_record.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/wallet/api/hb_api.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:titan/src/pages/wallet/wallet_show_trasaction_simple_info_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'entity/cross_chain_token.dart';
import 'dart:math' as math;

class CrossChainRecordListPage extends StatefulWidget {
  final CrossChainToken crossChainToken;

  CrossChainRecordListPage(this.crossChainToken);

  @override
  State<StatefulWidget> createState() {
    return _CrossChainRecordListPageState();
  }
}

class _CrossChainRecordListPageState extends State<CrossChainRecordListPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  AtlasApi _atlasApi = AtlasApi();

  int _currentPage = 1;
  int _size = 20;
  List<CrossChainRecord> _recordList = List();

  ///default token list
  CrossChainToken _currentToken = CrossChainToken('HYN', '', '');

  @override
  void initState() {
    super.initState();
    _updateTokenList();
    if (widget.crossChainToken != null) {
      _currentToken = widget.crossChainToken;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(baseTitle: '跨链记录'),
      body: Container(
        color: Colors.white,
        child: LoadDataContainer(
          bloc: _loadDataBloc,
          enablePullUp: _recordList.isNotEmpty,
          onLoadData: () {
            _refresh();
          },
          onRefresh: () {
            _refresh();
          },
          onLoadingMore: () {
            _loadMore();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _tokenSelection(),
              ),
              _content()
            ],
          ),
        ),
      ),
    );
  }

  _content() {
    if (_recordList.isEmpty) {
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
            return _crossChainRecordItem(_recordList[index]);
          },
          childCount: _recordList?.length ?? 0,
        ),
      );
    }
  }

  _crossChainRecordItem(CrossChainRecord record) {
    return Container(
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          if (record.type == null) return;
          if (record.type == 1) {
            WalletShowTransactionSimpleInfoPage.jumpToAccountInfoPage(
              context,
              record.atlasTx,
              _currentToken.symbol,
            );
          } else {
            HbApi.jumpToScanByHash(context, record.hecoTx);
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
              RichText(
                  text: TextSpan(
                      text: '${(record.type ?? 1) == 1 ? 'ATLAS' : 'HECO'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                    TextSpan(
                      text: ' 到 ',
                      style: TextStyles.textC999S13,
                    ),
                    TextSpan(
                      text: '${(record.type ?? 1) == 1 ? 'HECO' : 'ATLAS'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ])),
              SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${S.of(context).exchange_amount}(${record.symbol})',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          '${FormatUtil.weiToEtherStr(record.value)}',
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
                          '${BridgeUtil.getCrossChainStatusText(record.status)}',
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
                          '${FormatUtil.newFormatUTCDateStr(record.createdAt)}',
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
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: HexColor('#FF999999'),
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
      ),
    );
  }

  _tokenSelection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              _showTokenListDialog();
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset(
                          ImageUtil.getGeneralTokenLogo(_currentToken.symbol),
                          width: 32,
                          height: 32,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          _currentToken.symbol,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '切换币种 >',
                          style: TextStyle(color: Colors.blue),
                        )
                      ],
                    ),
                  ],
                )),
          ),
          Container(height: 8, color: DefaultColors.colorf2f2f2),
        ],
      ),
    );
  }

  _showTokenListDialog() async {
    var crossChainTokens = WalletInheritedModel.of(context).getCrossChainTokenList();
    UiUtil.showBottomDialogView(
      context,
      dialogHeight: MediaQuery.of(context).size.height - 80,
      isScrollControlled: true,
      customWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text(S.of(context).choose_currency, style: TextStyles.textC333S14bold),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              semanticChildCount: crossChainTokens.length,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final int itemIndex = index ~/ 2;
                      if (index.isEven) {
                        return _tokenItem(crossChainTokens[itemIndex]);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1),
                      );
                    },
                    semanticIndexCallback: (Widget widget, int localIndex) {
                      if (localIndex.isEven) {
                        return localIndex ~/ 2;
                      }
                      return null;
                    },
                    childCount: math.max(0, crossChainTokens.length * 2 - 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _tokenItem(CrossChainToken token) {
    return Column(
      children: [
        InkWell(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Container(
                  width: 48,
                  height: 48,
                  child: Image.asset(
                    ImageUtil.getGeneralTokenLogo(token.symbol),
                  ),
                ),
              ),
              Text(
                '${token.symbol}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
          onTap: () {
            _currentToken = token;
            setState(() {});
            _loadDataBloc.add(LoadingEvent());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future _refresh() async {
    _currentPage = 1;
    _recordList.clear();
    try {
      List<CrossChainRecord> list = await _atlasApi.getCrossChainRecord(
        WalletModelUtil.walletEthAddress,
        _currentToken.symbol,
        page: _currentPage,
        size: _size,
      );

      _recordList.addAll(list);
    } catch (e) {}
    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
  }

  _loadMore() async {
    try {
      List<CrossChainRecord> list = await _atlasApi.getCrossChainRecord(
        WalletModelUtil.walletEthAddress,
        _currentToken.symbol,
        page: _currentPage + 1,
        size: _size,
      );
      if (list.length > 0) {
        _currentPage++;
        _recordList.addAll(list);
      }
    } catch (e) {}
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
  }

  _updateTokenList() async {
    BlocProvider.of<WalletCmpBloc>(context)?.add(UpdateCrossChainTokenListEvent());
  }
}
