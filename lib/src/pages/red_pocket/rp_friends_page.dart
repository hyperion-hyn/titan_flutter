import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_miners_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'entity/rp_statistics.dart';

class RpFriendsPage extends StatefulWidget {
  RpFriendsPage();

  @override
  State<StatefulWidget> createState() {
    return _RpAddFriendsState();
  }
}

class _RpAddFriendsState extends BaseState<RpFriendsPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  int _currentPage = 1;
  var _address = "";

  List<RpMinerInfo> _myInviteList = List();
  RpMinerInfo _inviter;

  @override
  void initState() {
    super.initState();

    var activatedWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
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
        baseTitle: S.of(context).rp_friends,
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inviteBuilder(),
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 24, bottom: 6),
                  child: Text(
                    S.of(context).rp_my_invite_list,
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _myInviteListWidget(),
        ],
      ),
    );
  }

  _myInviteListWidget() {
    if (_myInviteList.isEmpty) {
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
                '暂无记录',
                style: TextStyle(
                  fontSize: 13,
                  color: DefaultColors.color999,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _itemBuilder(_myInviteList[index]);
          },
          childCount: _myInviteList.length,
        ),
      );
    }
  }

  Widget _inviteBuilder() {
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
                      S.of(context).rp_invite_me,
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
            _inviterWidget()
          ],
        ),
      ),
    );
  }

  _inviterWidget() {
    var inviterName = _inviter?.name ?? '';
    var inviterLevel = _inviter?.level ?? '';
    var inviterAddress = _inviter?.address ?? '';
    if (_inviter != null) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: SizedBox(
              height: 30,
              width: 30,
              child: walletHeaderWidget(
                inviterName,
                isShowShape: false,
                address: inviterAddress,
                isCircle: true,
              ),
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
                      inviterName,
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Text(
                  //   '$inviterLevel',
                  //   style: TextStyle(
                  //     color: HexColor("#999999"),
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.normal,
                  //   ),
                  // ),
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                '${UiUtil.shortEthAddress(inviterAddress)}',
                style: TextStyle(
                  fontSize: 10,
                  color: HexColor('#999999'),
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ],
      );
    } else {
      return Text('暂无',
          style: TextStyle(
            fontSize: 11,
            color: DefaultColors.color999,
          ));
    }
  }

  Widget _itemBuilder(RpMinerInfo info) {
    var name = info?.name ?? '';
    var level = info?.level ?? 0;
    var address = shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(
      info?.address ?? '',
    ));
    var inviteTime = info?.inviteTime ?? 0;
    var inviteTimeDate = DateTime.fromMillisecondsSinceEpoch(inviteTime * 1000);
    var inviteTimeStr = Const.DATE_FORMAT.format(inviteTimeDate);

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
              child: SizedBox(
                height: 30,
                width: 30,
                child: walletHeaderWidget(name,
                    address: info?.address ?? '',
                    isCircle: true,
                    isShowShape: false),
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
                      child: name.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: HexColor("#333333"),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ),
                    // Text(
                    //   ' $level 级',
                    //   style: TextStyle(
                    //     color: HexColor("#999999"),
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.normal,
                    //   ),
                    // ),
                  ],
                ),
                Text(
                  '${UiUtil.shortEthAddress(address)}',
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
                      inviteTimeStr,
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
    _myInviteList.clear();

    try {
      var netData = await _rpApi.getRPMinerList(
        _address,
        page: _currentPage,
      );

      _inviter = netData.inviter;
      _myInviteList = netData.miners ?? [];
      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
      setState(() {});
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData = await _rpApi.getRPMinerList(
        _address,
        page: _currentPage,
      );

      if (netData?.miners?.isNotEmpty ?? false) {
        _myInviteList.addAll(netData.miners);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }
}
