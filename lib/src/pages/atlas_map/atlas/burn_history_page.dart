import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
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
  List<String> _dataList = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  int _currentPage = 1;
  int _pageSize = 30;

  @override
  void initState() {
    super.initState();
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
        baseTitle: 'HYN燃烧',
        backgroundColor: Colors.grey[50],
      ),
      body: LoadDataContainer(
          bloc: _loadDataBloc,
          onLoadData: () async {
            await _refreshData();
          },
          onRefresh: () async {
            await _refreshData();
          },
          onLoadingMore: () {
            _loadMoreData();
            setState(() {});
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
                      Text('燃烧记录'),
                      Spacer(),
                      InkWell(
                          onTap: () {
                            AtlasApi.goToAtlasMap3HelpPage(context);
                          },
                          child: Text(
                            '关于燃烧',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return _burnHistoryItem();
              }, childCount: 10)),
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
            Text('历史累计燃烧'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${FormatUtil.stringFormatNum('10000')} HYN',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  _burnHistoryItem() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: InkWell(
        onTap: () {},
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
                      child: Text('第 40 纪元'),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            '燃烧 ${FormatUtil.stringFormatNum('11111111111')} HYN'),
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

  Future _refreshData() async {
    _currentPage = 1;
    _dataList.clear();

    var networkList;
    await Future.delayed(Duration(milliseconds: 1000), () {
      networkList = List.generate(10, (index) {
        return index.toString();
      });
    });

    if (networkList != null) {
      _dataList.addAll(networkList);
    }

    _loadDataBloc.add(RefreshSuccessEvent());
    if (mounted) setState(() {});
  }

  _loadMoreData() async {
    _currentPage++;

    var networkList;
    await Future.delayed(Duration(milliseconds: 1000), () {
      networkList = List.generate(10, (index) {
        return index.toString();
      });
    });

    if (networkList != null) {
      _dataList.addAll(networkList);
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());
    if (mounted) setState(() {});
  }
}
