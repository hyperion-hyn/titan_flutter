import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/pages/red_pocket/rp_level_un_staking_page.dart';
import 'package:titan/src/pages/red_pocket/rp_level_upgrade_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpMyLevelRecordsPage extends StatefulWidget {
  final RPStatistics rpStatistics;

  RpMyLevelRecordsPage(this.rpStatistics);

  @override
  State<StatefulWidget> createState() {
    return _RpMyLevelRecordsPageState();
  }
}

class _RpMyLevelRecordsPageState extends BaseState<RpMyLevelRecordsPage>
    with RouteAware {
  final RPApi _rpApi = RPApi();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  String get _address => _activeWallet?.wallet?.getEthAccount()?.address ?? "";

  WalletVo _activeWallet;
  RPStatistics _rpStatistics;
  int _currentPage = 1;
  List<RpStakingInfo> _dataList = [];

  @override
  void initState() {
    super.initState();

    _rpStatistics = widget.rpStatistics;

    _activeWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());

    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    super.onCreated();
  }

  @override
  void didPopNext() {
    getNetworkData();
  }

  @override
  void dispose() {
    super.dispose();
    Application.routeObserver.unsubscribe(this);
    _loadDataBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '持币量级',
        backgroundColor: HexColor('#F8F8F8'),
      ),
      body: LoadDataContainer(
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
          slivers: [
            _notificationWidget(),
            _myLevelInfo(),
            _myLevelRecordHeader(),
            _myLevelRecordList(),
          ],
        ),
      ),
    );
  }

  Widget _columnWidget(String amount, String title, {bool isBold = true}) {
    return Column(
      children: <Widget>[
        Text(
          '$amount',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: DefaultColors.color999,
          ),
        ),
      ],
    );
  }

  _notificationWidget() {
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: topNotifyWidget(
            notification: '新的燃烧25RP，抵押25.5RP交易确认中…',
            isWarning: false,
          ),
        ),
      ),
    );
  }

  _myLevelInfo() {
    int level = 0;
    var currentBurn = '--';
    var holding = '--';

    currentBurn = '30';
    holding = '200';

    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                  ),
                  child: Container(
                    child: Text(
                      '当前量级',
                      style: TextStyle(
                        color: HexColor('#333333'),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  "res/drawable/ic_rp_level_$level.png",
                  height: 100,
                ),
                if (level == 0)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 50,
                      right: 50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                          ),
                          child: Icon(
                            Icons.warning_outlined,
                            color: HexColor('#FF5041'),
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                            ),
                            child: Text(
                              '当前量级为0级，不能获得空投红包，请尽快升级',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 22,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                        ),
                        child: _columnWidget(
                          '$currentBurn RP',
                          '当前燃烧',
                        ),
                        // child: _columnWidget('$totalTransmit RP', '总可传导'),
                      ),
                      Spacer(),
                      _columnWidget(
                        '$holding RP',
                        '当期持币',
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            child: ClickOvalButton(
                              '升级/增持',
                              _navToLevelUpgradeAction,
                              width: 120,
                              height: 32,
                              fontSize: 12,
                              btnColor: [HexColor('#00B97C')],
                            ),
                            padding: const EdgeInsets.all(
                              16,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Image.asset(
                              "res/drawable/red_pocket_exchange_hot.png",
                              width: 35,
                              height: 20,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      ClickOvalButton(
                        '取回持币',
                        _navToLevelUnStakingAction,
                        width: 120,
                        height: 32,
                        fontSize: 12,
                        btnColor: [HexColor('#107EDC')],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _myLevelRecordHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: HexColor('#F8F8F8'),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 18,
            bottom: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                '量级记录',
                style: TextStyle(
                  color: HexColor("#333333"),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _myLevelRecordList() {
    if (_dataList?.isEmpty ?? true) {
      return SliverToBoxAdapter(
        child: Container(
          color: HexColor('#F8F8F8'),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0, bottom: 160),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: emptyListWidget(
                  title: S.of(context).rp_empty_staking_record,
                  isAdapter: false),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _itemBuilder(index);
        },
        childCount: _dataList?.length ?? 0,
      ),
    );
  }

  Widget _itemBuilder(index) {
    var model = _dataList[index];
    var status = model?.status ?? 0;
    var hynAmountBig = ConvertTokenUnit.strToBigInt(model?.hynAmount ?? '0');
    var hynPerRpBig = ConvertTokenUnit.strToBigInt(
        _rpStatistics?.rpContractInfo?.hynPerRp ?? '0');
    var amountBig = (hynAmountBig / hynPerRpBig);

    if (amountBig.isNaN || amountBig.isInfinite) {
      amountBig = 0;
    }

    var amount = amountBig.toInt();
    if (amount.isNaN) {
      amount = 1;
    }

    var stakingAt =
        FormatUtil.newFormatUTCDateStr(model?.stakingAt ?? '0', isSecond: true);
    var expectReleaseTime = FormatUtil.newFormatUTCDateStr(
        model?.expectRetrieveTime ?? '0',
        isSecond: true);

    bool isUp = index % 2 == 0;

    return InkWell(
      child: Stack(
        children: [
          Container(
            color: HexColor('#F8F8F8'),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
              ),
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
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                          ),
                          child: Image.asset(
                            "res/drawable/red_pocket_level_${isUp ? 'up' : 'down'}.png",
                            width: 22,
                            height: 22,
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
                                    '$amount 级',
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              '0 级-2 级',
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor('#999999'),
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
                              '燃烧 60RP，抵押63RP',
                              style: TextStyle(
                                color: HexColor("#333333"),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              '${stakingAt ?? '--'}',
                              //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(model?.createdAt)),
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
                    if (status >= 3 && status <= 5)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${expectReleaseTime ?? '--'}${S.of(context).rp_hyn_can_retrieved}',
                              //DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(createAt)),
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor('#999999'),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              right: 26,
              top: 4,
              child: Container(
                decoration: BoxDecoration(
                    color: HexColor("#FF4C3B"),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 1, 8, 3),
                  child: Center(
                    child: Text(
                      'new',
                      style: TextStyle(
                          fontSize: 10,
                          color: HexColor("#FFFFFF"),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void getNetworkData() async {
    _currentPage = 1;
    try {
      var netData = await _rpApi.getRPStakingInfoList(
        _address,
        page: _currentPage,
      );

      _rpStatistics = await _rpApi.getRPStatistics(_address);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }

      if (netData?.isNotEmpty ?? false) {
        _dataList = netData;
      }
      // } else {
      //   _loadDataBloc.add(LoadEmptyEvent());
      // }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  void getMoreNetworkData() async {
    try {
      _currentPage = _currentPage + 1;
      var netData =
          await _rpApi.getRPStakingInfoList(_address, page: _currentPage);

      if (netData?.isNotEmpty ?? false) {
        _dataList.addAll(netData);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadMoreFailEvent());
    }
  }

  _navToLevelUnStakingAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelRetrievePage(),
      ),
    );
  }

  _navToLevelUpgradeAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelUpgradePage(),
      ),
    );
    return;
  }
}
