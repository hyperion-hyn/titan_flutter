import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';


class RedPocketExchangeRecordsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RedPocketExchangeRecordsState();
  }
}

class _RedPocketExchangeRecordsState extends BaseState<RedPocketExchangeRecordsPage> {
  LoadDataBloc loadDataBloc = LoadDataBloc();

  int _currentPage = 0;
  final AtlasApi _atlasApi = AtlasApi();
  var _address = "";
  List<Map3InfoEntity> _dataList = [];

  @override
  void initState() {
    super.initState();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void onCreated() {
    loadDataBloc.add(LoadingEvent());
  }

  void getNetworkData() async {
    try {
      var netData = await _atlasApi.getMap3StakingList(_address, page: _currentPage, size: 10);

      if (netData?.map3Nodes?.isNotEmpty??false) {
        _dataList = netData.map3Nodes;
        if (mounted) {
          setState(() {
            loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        loadDataBloc.add(LoadFailEvent());
      }
    } catch (e) {
      loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _atlasApi.getMap3StakingList(_address, page: _currentPage, size: 10);

      if (netData?.map3Nodes?.isNotEmpty??false) {
        _dataList = netData.map3Nodes;
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F8F8'),
      appBar: BaseAppBar(
        baseTitle: '传导明细',
        backgroundColor: HexColor('#F8F8F8'),
      ),
      body: _pageView(),
    );
  }

  _pageView() {
    return LoadDataContainer(
      bloc: loadDataBloc,
      onLoadData: () async {
        getNetworkData();
      },
      onRefresh: () async {
        getNetworkData();
      },
      onLoadingMore: () {
        getMoreNetworkData();
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) {
              var key = '昨天';
              return Container(
                color: HexColor('#F8F8F8'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    key?.isNotEmpty ?? false
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                              left: 12,
                            ),
                            child: Text(
                              key ?? '',
                              style: TextStyle(
                                color: HexColor("#999999"),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          )
                        : Container(),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _dataList.length,
                        itemBuilder: (context, index) {
                          var createAt = DateTime.now().millisecondsSinceEpoch;

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: HexColor('#FFFFFF'),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6.0),
                                ), //设置四周圆角 角度
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10,
                                    ),
                                    child: Image.asset(
                                      "res/drawable/red_pocket_coins.png",
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            child: Text(
                                              '2 份',
                                              style: TextStyle(
                                                color: HexColor("#333333"),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '共 1000 HYN',
                                            style: TextStyle(
                                              color: HexColor("#999999"),
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6,),
                                      Text(
                                        '抵押ID：3',
                                        //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor('#333333'),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '+ 10RP',
                                        style: TextStyle(
                                          color: HexColor("#333333"),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 6,),
                                      Text(
                                        '21:21:21',
                                        //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor('#999999'),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              );
            },
            childCount: 10,
          ))
        ],
      ),
    );
  }
}
