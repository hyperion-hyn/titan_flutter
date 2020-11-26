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
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';

import 'entity/rp_release_info.dart';


class RpReleaseRecordsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpReleaseRecordsState();
  }
}

class _RpReleaseRecordsState extends BaseState<RpReleaseRecordsPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();

  int _currentPage = 1;
  RPApi _rpApi = RPApi();
  var _address = "";
  List<RPReleaseInfo> _dataList = [];

  @override
  void initState() {
    super.initState();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());
  }

  void getNetworkData() async {
    try {
      var netData = await _rpApi.getRPReleaseInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty??false) {
        _dataList = netData;
        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPReleaseInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty??false) {
        _dataList = netData;
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
      setState(() {});
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  @override
  void dispose() {
    _loadDataBloc.close();
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
      bloc: _loadDataBloc,
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
            },
            childCount: _dataList?.length,
          ))
        ],
      ),
    );
  }
}
