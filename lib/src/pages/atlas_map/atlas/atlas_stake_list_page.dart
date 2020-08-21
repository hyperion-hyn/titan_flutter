import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class AtlasStakeListPage extends StatefulWidget {
  AtlasStakeListPage();

  @override
  State<StatefulWidget> createState() {
    return AtlasStakeListPageState();
  }
}

class AtlasStakeListPageState extends State<AtlasStakeListPage> {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "抵押Atlas节点",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      body: LoadDataContainer(
          bloc: _loadDataBloc,
          onLoadData: () {
            _refreshData();
          },
          onRefresh: () {
            _refreshData();
          },
          onLoadingMore: () {
            _loadMoreData();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0, bottom: 20),
                      child: stakeHeaderInfo(context),
                    ),
                    Container(
                      height: 10,
                      color: HexColor("#F2F2F2"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 14, right: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "参与抵押",
                            style: TextStyles.textC333S16,
                          ),
                          Spacer(),
                          Text(
                            "共12个节点",
                            style: TextStyles.textC999S12,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                  children: <Widget>[
                    SizedBox(height: 17,),
                    Padding(
                      padding: const EdgeInsets.only(left: 26.0, right: 26),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipOval(
                                child: Image.network("http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png",
                                    fit: BoxFit.cover, width: 44, height: 44)),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Moo",style: TextStyles.textC000S14),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0, bottom: 2),
                                  child: Text("03fklsdflksm",style: TextStyles.textC999S12),
                                ),
                                Text("预期年化：10.0%",style: TextStyles.textC333S12),
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Text("20,000",style: TextStyles.textC333S14),
                              SizedBox(height: 13,),
                              ClickOvalButton(
                                "抵押",
                                () {},
                                width: 52,
                                height: 22,
                                fontSize: 12,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 14,),
                    Divider(color: DefaultColors.colorf2f2f2,indent: 26,endIndent: 26,)
                  ],
                );
              }, childCount: _dataList.length))
            ],
          )),
    );
  }

  _refreshData() async {
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
