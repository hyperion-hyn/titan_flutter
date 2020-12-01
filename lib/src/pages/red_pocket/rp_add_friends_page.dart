import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_miners_entity.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'entity/rp_statistics.dart';

class RpAddFriendsPage extends StatefulWidget {
  final RPStatistics rpStatistics;

  RpAddFriendsPage(this.rpStatistics);

  @override
  State<StatefulWidget> createState() {
    return _RpAddFriendsState();
  }
}

class _RpAddFriendsState extends BaseState<RpAddFriendsPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  int _currentPage = 1;
  var _address = "";
  List<RpMinerInfo> _dataList = [];
  RpMinersEntity _rpMinersEntity;
  RpMinerInfo get _inviterInfo => _rpMinersEntity?.inviter;

  int lastDay;

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
        baseTitle: '朋友圈',
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
              var model = _dataList[index];

              bool isFirstRow = false;
              if (index == 0) {
                isFirstRow = true;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstRow) _inviteBuilder(index),
                  if (isFirstRow)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 24, bottom: 6),
                      child: Text(
                        '我邀请的好友',
                        style: TextStyle(
                          color: Color(0xff333333),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  _itemBuilder(index),
                ],
              );
            },
            childCount: _dataList?.length ?? 0,
          ))
        ],
      ),
    );
  }

  Widget _inviteBuilder(int index) {
    var model = _inviterInfo;

    var currentDate = DateTime.fromMillisecondsSinceEpoch(model.inviteTime * 1000);
    var updatedAt = Const.DATE_FORMAT.format(currentDate);

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Text(
                      '邀请我',
                      style: TextStyle(
                        fontSize: 14,
                        color: HexColor('#333333'),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: Image.asset(
                "res/drawable/ic_map3_node_default_icon.png",
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
                        model?.name??'',
                        style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${model?.level??0}',
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  '${UiUtil.shortEthAddress(model?.address??'')}',
                  //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor('#999999'),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            //Spacer(),

          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) {
    var model = _dataList[index];

    var currentDate = DateTime.fromMillisecondsSinceEpoch(model.inviteTime * 1000);
    var updatedAt = Const.DATE_FORMAT.format(currentDate);

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
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
                "res/drawable/ic_map3_node_default_icon.png",
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
                        model?.name??'',
                        style: TextStyle(
                          color: HexColor("#333333"),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      ' ${model?.level??0} 级',
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  '${UiUtil.shortEthAddress(model?.address??'')}',
                  //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor('#999999'),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            //Spacer(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Text(
                      updatedAt,
                      //'21:21:21',
                      style: TextStyle(
                        fontSize: 12,
                        color: HexColor('#999999'),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getNetworkData() async {
    _currentPage = 1;

    try {
      var netData = await _rpApi.getRPMinerList(_address, page: _currentPage);

      _rpMinersEntity = netData;

      if (netData?.miners?.isNotEmpty ?? false) {
        _dataList = netData.miners;
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
      var netData = await _rpApi.getRPMinerList(_address, page: _currentPage);

      if (netData?.miners?.isNotEmpty ?? false) {
        _dataList.addAll(netData.miners);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
