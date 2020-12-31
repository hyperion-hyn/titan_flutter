import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/token_burn_info_page.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

class BurnHistoryPage extends StatefulWidget {
  BurnHistoryPage();

  @override
  State<StatefulWidget> createState() {
    return BurnHistoryPageState();
  }
}

class BurnHistoryPageState extends State<BurnHistoryPage> {
  List<BurnHistory> _burnHistoryList = List();
  BurnMsg _burnMsg;

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  AtlasApi _atlasApi = AtlasApi();

  int _currentPage = 1;
  int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _getBurnMsg();
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).hyn_burning,
        backgroundColor: Colors.grey[50],
      ),
      body: LoadDataContainer(
          bloc: _loadDataBloc,
          onLoadData: () async {
            _getBurnMsg();
            await _refreshData();
          },
          onRefresh: () async {
            _getBurnMsg();
            await _refreshData();
          },
          onLoadingMore: () async {
            _getBurnMsg();
            await _loadMoreData();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _burnInfo(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      Text(S.of(context).burning_record),
                      Spacer(),
                      InkWell(
                          onTap: () {
                            AtlasApi.goToAtlasMap3HelpPage(context);
                          },
                          child: Text(
                            S.of(context).about_burning,
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              _burnHistoryList.length != 0
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _burnHistoryItem(_burnHistoryList[index]);
                      },
                      childCount: _burnHistoryList.length,
                    ))
                  : _emptyListHint(),
            ],
          )),
    );
  }

  _burnInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'HYN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '（Hyperion Token）',
                    style: TextStyle(
                      color: DefaultColors.color999,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Image.asset(
                'res/drawable/img_volcano.png',
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(S.of(context).historical_cumulative_burning),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${_burnMsg?.getTotalAmountStr()} HYN',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                  bottom: 24.0,
                  right: 16.0,
                  left: 16.0,
                ),
                child: Text(
                  S.of(context).internal_external_combustion_increasing_value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: DefaultColors.color999,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  _burnHistoryItem(BurnHistory burnHistory) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: InkWell(
        onTap: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TokenBurnInfoPage(burnHistory),
              ));
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(6.0),
              )),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '第 ${burnHistory.id} 轮',
                            style: TextStyle(fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                            ),
                            child: Text(
                              '区块高度 ${burnHistory.block}',
                              style: TextStyle(
                                fontSize: 12,
                                color: DefaultColors.color999,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '燃烧 ${FormatUtil.stringFormatCoinNum(burnHistory.getTotalAmount())} HYN',
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            ),
                            if ((burnHistory.type ?? 1) == 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  right: 4.0,
                                ),
                                child: Text(
                                  S.of(context).creation_burn,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DefaultColors.color999,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: DefaultColors.color999,
                      size: 15,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getBurnMsg() async {
    try {
      _burnMsg = await _atlasApi.postBurnMsg();
    } catch (e) {}
    if (mounted) setState(() {});
  }

  _emptyListHint() {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'res/drawable/ic_empty_contract.png',
                width: 100,
                height: 100,
              ),
            ),
            Text(
              S.of(context).exchange_empty_list,
              style: TextStyle(
                fontSize: 13,
                color: DefaultColors.color999,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _refreshData() async {
    _currentPage = 1;
    _burnHistoryList.clear();
    try {
      var _list = await _atlasApi.postBurnHistoryList(
        status: 2,
        page: _currentPage,
        size: _pageSize,
      );

      if (_list != null) {
        _burnHistoryList.clear();
        _burnHistoryList.addAll(_list);
      }
      _loadDataBloc.add(RefreshSuccessEvent());
    } catch (e) {
      _loadDataBloc.add(RefreshFailEvent());
    }
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    try {
      var _list = await _atlasApi.postBurnHistoryList(
        status: 2,
        page: _currentPage + 1,
        size: _pageSize,
      );

      if (_list != null && _list.isNotEmpty) {
        _burnHistoryList.addAll(_burnHistoryList);
        _currentPage++;
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
    if (mounted) setState(() {});
  }
}
